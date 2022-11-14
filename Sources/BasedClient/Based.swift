//
//  Based.swift
//  
//
//  Created by Alexander van der Werff on 29/08/2021.
//

import Foundation
import NakedJson

public final class Based {
    
    public struct Opts {
        public let env: String?
        public let project: String?
        public let org: String?
        public var cluster: String
        public let name: String
        public let params: [String: String]?
        public var urlString: String? = nil
        public init(
            env: String? = nil,
            project: String? = nil,
            org: String? = nil,
            cluster: String = "https://d15p61sp2f2oaj.cloudfront.net",
            name: String = "@based/hub",
            params: [String: String]? = nil) {
                self.env = env
                self.project = project
                self.org = org
                self.cluster = cluster
                self.name = name
                self.params = params
        }
    }
    
    var config: BasedConfig
    
    let decoder = JSONDecoder()
    
    let encoder = JSONEncoder()
    
    let emitter: Emitter
    
    let socket: BasedWebSocket
    
    var subscriptionManager = SubscriptionManager()
    
    var cache: Cache = Cache()
    
    var token: String? = "token"
    
    var beingAuth = false
    
    var sendTokenOptions: SendTokenOptions?
    
    var messageManager: MessageManager
    
    var messages: Messages
    
    var auth: [AuthFunction] = []
    
    typealias RequestId = Int
    typealias RequestCallbacks = Dictionary<RequestId, RequestCallback>
    var requestIdCnt: Int = 0
    var requestCallbacks = RequestCallbacks()
    
    public required convenience init(opts: Opts) {
        let urlSessionConfig = URLSessionConfiguration.default
        urlSessionConfig.waitsForConnectivity = true
        urlSessionConfig.timeoutIntervalForRequest = 4
        urlSessionConfig.requestCachePolicy = .reloadIgnoringLocalAndRemoteCacheData
        let session = URLSession(configuration: urlSessionConfig)
        let config = BasedConfig(opts: opts, urlSession: session)
        self.init(config: config, ws: BasedWebSocket(), emitter: Emitter(), messages: Messages())
    }
    
    internal init(
        config: BasedConfig,
        ws: BasedWebSocket,
        emitter: Emitter,
        messages: Messages
    ) {
        
        self.config = config
        self.socket = ws
        self.emitter = emitter
        self.messages = messages
        messageManager = MessageManager(messages: messages, socket: ws)
        self.socket.delegate = self
        Task {
            do {
                let finalUrl = try await config.url
                connect(with: finalUrl)
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    deinit {
        self.socket.disconnect()
    }
    
    public func connect(with url: URL) {
        socket.connect(url: url)
    }

    public func disconnect() {
        guard socket.connected else { return }
        socket.disconnect()
        onClose()
    }
}


extension Based: BasedWebSocketDelegate {
    
    func onClose() {
        Task {
            await messageManager.cancelAll()
            await messages.removeSubscriptionMessages(with: .unsubscribe)
            await messages.removeSubscriptionMessages(with: .sendSubscriptionData)
        }
        emitter.emit(type: .disconnect)
    }
    
    func onReconnect() {
        emitter.emit(type: .reconnect)
    }
    
    func onOpen() {
        emitter.emit(type: .connect)
        Task {
            await sendToken(token, sendTokenOptions)
            await sendAllSubscriptions()
            await messageManager.sendAllMessages()
        }
    }
    
    func onError(_: Error?) {}
    
    func onData(data: URLSessionWebSocketTask.Message) {
        switch data {
        case .string(let json):
            guard
                let jsonData = json.data(using: .utf8),
                let dataMessage = try? decoder.decode([Json].self, from: jsonData)
            else { return }
            
            switch RequestType(rawValue: dataMessage[0].intValue ?? -1) {
            case .token?:
                if let data = dataMessage[1].intArrayValue, dataMessage.count > 1 {
                    Task { await logoutSubscriptions(data) }
                }
                if let state = dataMessage[2].boolValue {
                    auth.forEach { auth in
                        auth.resolve(!state)
                    }
                }
                beingAuth = false
                auth = []
            case .set?, .get?, .configuration?, .getConfiguration?, .call?, .delete?, .copy?, .digest?:
                incomingRequest(dataMessage)
            case .subscription?:
                //ex: [1,-1725702994954,{\"$isNull\":true},3391353116945]
                if
                    let id = dataMessage[1].intValue,
                    let checksum = dataMessage[3].intValue,
                    let jsonData = try? encoder.encode(dataMessage[2]) {
                    
                    Task {
                        var error: ErrorObject?
                        if dataMessage.count > 4 {
                            error = .init(from: dataMessage[4])
                        }
                        await incomingSubscription(SubscriptionData(id: id, data: jsonData, checksum: checksum, error: error))
                    }
                }
            case .subscriptionDiff?:
                let diff = dataMessage[2]
                
                guard
                    let id = dataMessage[1].intValue,
                    let checksums = dataMessage[3].intArrayValue,
                        checksums.count > 1
                else {
                    return
                }
                    
                let previous = checksums[0]
                let current = checksums[1]
                
                Task { await  incomingSubscriptionDiff(SubscriptionDiffData(id: id, patchObject: diff, checksums: (previous: previous, current: current))) }
            default:
                print("no match")
            }
            
        default: break
        }
    }
    
}

extension Json {
    var intArrayValue: [Int]? {
        guard
            let result = arrayValue?.map(\.intValue),
            result.allSatisfy({ $0 != nil })
        else { return nil }
        
        return result.compactMap { $0 }
    }
}
