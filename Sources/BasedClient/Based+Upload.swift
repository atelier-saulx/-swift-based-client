//
//  Based+File.swift
//  
//
//  Created by Alexander van der Werff on 20/01/2022.
//

#if os(iOS)

import Foundation
import Combine

struct UploadOptions {
    enum UploadType {
        case data(_ data: Data)
        case file(_ file: URL)
    }
    let uploadType: UploadType
    let targetUrl: URL?
    let name: String?
    let id: String?
    let mimeType: String?
}

struct Upload {
    var uploadType: UploadOptions.UploadType
    let targetUrl: URL
    let name: String?
    let id: String?
    let mimeType: String?
    let token: String
}

public enum UploadStatus {
    case progress(Double)
    case uploaded(id: String?)
}

final class Uploader: NSObject {
    typealias Percentage = Double
    typealias Publisher = AnyPublisher<UploadStatus, Error>
    
    private typealias Subject = CurrentValueSubject<UploadStatus, Error>
    
    private lazy var urlSession = URLSession(
        configuration: .default,
        delegate: self,
        delegateQueue: .main
    )
    
    private var subjectsByTaskID = [Int: Subject]()
    
    func uploadFile(_ upload: Upload) -> Publisher {
        
        let subject = Subject(.progress(0))
        var removeSubject: (() -> Void)?
        
        var request = URLRequest(
            url: upload.targetUrl,
            cachePolicy: .reloadIgnoringLocalCacheData
        )

        request.httpMethod = "POST"
        request.setValue("blob", forHTTPHeaderField: "Req-Type")
        request.setValue(upload.mimeType ?? "text/plain", forHTTPHeaderField: "Content-Type")
        request.setValue(upload.id ?? "", forHTTPHeaderField: "File-Id")
        request.setValue(upload.name ?? "", forHTTPHeaderField: "File-Name")
        request.setValue(upload.token, forHTTPHeaderField: "Authorization")
        request.setValue("chunked", forHTTPHeaderField: "Transfer-Encoding")
        
        let task: URLSessionUploadTask
        switch upload.uploadType {
        case .file(let fileURL):
            task = urlSession.uploadTask(
                with: request,
                fromFile: fileURL,
                completionHandler: { data, response, error in
                    if let error = error {
                        subject.send(completion: .failure(error))
                        return
                    }
//                    if let data = data, let res = try? JSONDecoder().decode([String: String].self, from: data) {
//                        subject.send(.uploaded(id: res["id"]))
//                    }
                    subject.send(.uploaded(id: upload.id))
                    subject.send(completion: .finished)
                    removeSubject?()
                }
            )
        case .data(let data):
            task = urlSession.uploadTask(
                with: request,
                from: data,
                completionHandler: { data, response, error in
                    if let error = error {
                        subject.send(completion: .failure(error))
                        return
                    }
//                    if let data = data, let res = try? JSONDecoder().decode([String: String].self, from: data) {
//                        subject.send(.uploaded(id: res["id"]))
//                    }
                    subject.send(.uploaded(id: upload.id))
                    subject.send(completion: .finished)
                    removeSubject?()
                }
            )
        }
        
        subjectsByTaskID[task.taskIdentifier] = subject
        removeSubject = { [weak self] in
            self?.subjectsByTaskID.removeValue(forKey: task.taskIdentifier)
        }
        
        task.resume()
        
        return subject.eraseToAnyPublisher()
    }
}

extension Uploader: URLSessionTaskDelegate {
    func urlSession(
        _ session: URLSession,
        task: URLSessionTask,
        didSendBodyData bytesSent: Int64,
        totalBytesSent: Int64,
        totalBytesExpectedToSend: Int64
    ) {
        let progress = Double(totalBytesSent) / Double(totalBytesExpectedToSend)
        let subject = subjectsByTaskID[task.taskIdentifier]
        subject?.send(.progress(progress))
    }
}

extension Based {

    /**
     
     */
    public func upload(
        fileUrl: URL,
        targetUrl: URL? = nil,
        mimeType: String? = nil,
        name: String? = nil,
        id: String? = nil
    ) -> AnyPublisher<UploadStatus, Error> {
        return _upload(options: UploadOptions(uploadType: .file(fileUrl), targetUrl: targetUrl, name: name, id: id, mimeType: mimeType))
    }
    
    /**
     
     */
    public func upload(
        data: Data,
        targetUrl: URL? = nil,
        mimeType: String? = nil,
        name: String? = nil,
        id: String? = nil
    ) -> AnyPublisher<UploadStatus, Error> {
        return _upload(options: UploadOptions(uploadType: .data(data), targetUrl: targetUrl, name: name, id: id, mimeType: mimeType))
    }
    
    private func _upload(options: UploadOptions) -> AnyPublisher<UploadStatus, Error> {
        Just((options, token))
            .setFailureType(to: Error.self)
            .asyncMap { [weak self] args -> Upload in
                let (options, token) = args
                
                guard let token = token else {
                    throw BasedError.missingToken(message: "Token not found")
                }
                
                guard let targetUrl = try await self?.getUrl(options: options) else {
                    throw BasedError.noValidURL(message: "Could not construct target url for file upload")
                }
            
                var id = options.id
                if id == nil {
                    id = try await self?.set(query: .query(.field("type", "file")))
                }
                
                return Upload(
                    uploadType: options.uploadType,
                    targetUrl: targetUrl,
                    name: options.name,
                    id: id,
                    mimeType: options.mimeType,
                    token: token
                )
        
            }
            .flatMap { upload -> AnyPublisher<UploadStatus, Error> in
                let uploader = Uploader()
                return uploader.uploadFile(upload)
            }.eraseToAnyPublisher()
    }
    
    private func getUrl(options: UploadOptions) async throws -> URL {
        if let targetUrl = options.targetUrl {
            return targetUrl
        } else {
            let targetUrl = try await config.url
            let urlString = targetUrl.absoluteString.replacingOccurrences(of: "ws", with: "http")
            if config.opts.env == nil, let url = URL(string: "\(urlString)") {
                return url
            } else if let url = URL(string: "\(urlString)/file") {
                return url
            }
        }
        throw BasedError.noValidURL(message: "Could not construct target url for file upload")
    }
}

extension Publisher {
    func asyncMap<T>(
        _ transform: @escaping (Output) async throws -> T
    ) -> Publishers.FlatMap<Future<T, Error>, Self> {
        flatMap { value in
            Future { promise in
                Task {
                    do {
                        let output = try await transform(value)
                        promise(.success(output))
                    } catch {
                        promise(.failure(error))
                    }
                }
            }
        }
    }
}

#endif
