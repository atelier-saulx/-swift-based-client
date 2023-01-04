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
                    if let data = data, let res = try? JSONDecoder().decode([String: String].self, from: data) {
                        subject.send(.uploaded(id: res["id"]))
                    }
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
                    if let data = data, let res = try? JSONDecoder().decode([String: String].self, from: data) {
                        subject.send(.uploaded(id: res["id"]))
                    }
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
        Just((options, "token"))
            .setFailureType(to: Error.self)
            .asyncMap { [weak self] args -> Upload in
                
                guard
                    let self = self,
                    let targetUrl = URL(string: Current.basedClient.service(org: self.configuration.org, project: self.configuration.project, env: self.configuration.env))
                else {
                    throw BasedError.uploadError(message: "Could not create upload url")
                }
            
                let (options, token) = args
                
                var id = options.id
                if id == nil {
                    id = try await self.set(query: .query(.field("type", "file")))
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
