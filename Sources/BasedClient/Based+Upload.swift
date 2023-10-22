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
    let mimeType: String?
    let authToken: String //security token
}

struct Upload {
    var uploadType: UploadOptions.UploadType
    let targetUrl: URL
    let name: String?
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
        request.setValue("chunked", forHTTPHeaderField: "Transfer-Encoding")
        request.setValue(upload.token, forHTTPHeaderField: "JSON-authorization")
        request.setValue(upload.mimeType ?? "text/plain", forHTTPHeaderField: "Content-Type")

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
     upload function is used to upload a file to a specified URL.
     - Parameters:
        - fileUrl: A `URL` object representing the file to be uploaded.
        - targetUrl: (Optional) A `URL` object representing the target URL where the file should be uploaded. If not provided, the file will be uploaded to the default target URL.
        - mimeType: (Optional) A `String` representing the mime type of the file. If not provided, the mime type will be inferred from the file extension.
        - name: (Optional) A `String` representing the name of the file. If not provided, the file name will be used.
     - Returns: An `AnyPublisher<UploadStatus, Error>` object that emits an `UploadStatus` value upon successful completion and an `Error` object in case of failure.
     */
    public func upload(
        fileUrl: URL,
        targetUrl: URL? = nil,
        mimeType: String? = nil,
        name: String? = nil,
        authToken: String
    ) -> AnyPublisher<UploadStatus, Error> {
        return _upload(options: UploadOptions(uploadType: .file(fileUrl), targetUrl: targetUrl, name: name, mimeType: mimeType, authToken: authToken))
    }

    /**
     upload function is used to upload a file to a specified URL.
     - Parameters:
        - data: Data object representing the file to be uploaded.
        - targetUrl: (Optional) A `URL` object representing the target URL where the file should be uploaded. If not provided, the file will be uploaded to the default target URL.
        - mimeType: (Optional) A `String` representing the mime type of the file. If not provided, the mime type will be inferred from the file extension.
        - name: (Optional) A `String` representing the name of the file. If not provided, the file name will be used.
     - Returns: An `AnyPublisher<UploadStatus, Error>` object that emits an `UploadStatus` value upon successful completion and an `Error` object in case of failure.
     */
    public func upload(
        data: Data,
        targetUrl: URL? = nil,
        mimeType: String? = nil,
        name: String? = nil,
        authToken: String
    ) -> AnyPublisher<UploadStatus, Error> {
        return _upload(options: UploadOptions(uploadType: .data(data), targetUrl: targetUrl, name: name, mimeType: mimeType, authToken: authToken))
    }

    private func _upload(options: UploadOptions) -> AnyPublisher<UploadStatus, Error> {
        Just(options)
            .setFailureType(to: Error.self)
            .asyncMap { [weak self] options -> Upload in
                guard
                    let self = self,
                    let targetUrl = URL(string: Current.basedClient.service(
                            org: self.configuration.org,
                            project: self.configuration.project,
                            env: self.configuration.env,
                            html: true
                        )
                        .appending("/db:file-upload")
                    )
                else {
                    throw BasedError.uploadError(message: "Could not create upload url")
                }

                let urlEncodedJson = "{\"token\":\"\(options.authToken)\"}".addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed) ?? ""

                return Upload(
                    uploadType: options.uploadType,
                    targetUrl: targetUrl,
                    name: options.name,
                    mimeType: options.mimeType,
                    token: urlEncodedJson
                )

            }
            .flatMap { upload -> AnyPublisher<UploadStatus, Error> in
                let uploader = Uploader()
                return uploader.uploadFile(upload)
            }
            .eraseToAnyPublisher()
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
