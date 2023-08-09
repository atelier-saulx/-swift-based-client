//
//  BasedClient.swift
//  
//
//  Created by Alexander van der Werff on 11/11/2022.
//

import Foundation
@_exported import BasedOBJCWrapper

/// /// Client id returned from a Based C++ Client
typealias BasedClientId = CInt
/// Callback id present in get callbacks and function callbacks
typealias CallbackId = CInt
/// Observe id present in subscription callbacks
typealias ObserveId = CInt
/// Get or Function callback
typealias Callback = @Sendable (_ data: String, _ error: String) -> ()
/// Observe callback
typealias ObserveCallback = @Sendable (_ data: String, _ checksum: UInt64, _ error: String, _ observeId: ObserveId) -> ()
/// Auth callback
typealias AuthCallback = @Sendable (_ data: String) -> ()


/// Observe callback store
@globalActor
actor ObserveCallbacks {
    static var shared: CallbacksStore<ObserveId, ObserveCallback> = .init()
}

/// Get callback store
@globalActor
actor GetCallbacks {
    static var shared: CallbacksStore<CallbackId, Callback> = .init()
}

/// Get callback store
@globalActor
actor FunctionCallbacks {
    static var shared: CallbacksStore<CallbackId, Callback> = .init()
}

/// Because C funciton pointers cannot have context it is needed to handle all callbacks first global, it is guaranteed that the char pointers will always point to a String which
/// could be an empty String

/// Handler types
enum HandlerType {
    case get(id: CallbackId, data: String, error: String)
    case observe(id: ObserveId, data: String, checksum: UInt64, error: String)
    case function(id: CallbackId, data: String, error: String)
    case auth(data: String)
}

//func handleAuth(clientId: BasedClientId) -> (_ data: UnsafePointer<CChar>) -> () {
//    return { data in
//        let dataString = String(cString: data)
//        dataInfo("AUTH DATA:: \(dataString)")
//        guard dataString.isEmpty == false else { return }
//        BasedClient.clients[clientId]?.callbackHandler(with: .auth(data: dataString))
//    }
//}
/// Callback for auth
private func handleAuthCallback(data: UnsafePointer<CChar>) {
    let dataString = String(cString: data)
    guard dataString.isEmpty == false else { return }
    Current.basedClient.callbackHandler(with: .auth(data: dataString))
}

/// Callback get handler
/// Dealing with c pointer functions forces a global approach
private func handleGetCallback(data: UnsafePointer<CChar>, error: UnsafePointer<CChar>, subscriptionId: CInt) {
    let dataString = String(cString: data)
    let errorString = String(cString: error)
    Current.basedClient.callbackHandler(with: .get(id: subscriptionId, data: dataString, error: errorString))
}

/// Callback function handler
private func handleFunctionCallback(data: UnsafePointer<CChar>, error: UnsafePointer<CChar>, subscriptionId: CInt) {
    let dataString = String(cString: data)
    let errorString = String(cString: error)
    Current.basedClient.callbackHandler(with: .function(id: subscriptionId, data: dataString, error: errorString))
}

/// Observe callback handler
private func handleObserveCallback(data: UnsafePointer<CChar>, checksum: UInt64, error: UnsafePointer<CChar>, observeId: CInt) {
    let dataString = String(cString: data)
    let errorString = String(cString: error)
    Current.basedClient.callbackHandler(with: .observe(id: observeId, data: dataString, checksum: checksum, error: errorString))
}

final class BasedClient: BasedClientProtocol {

    var authCallback: AuthCallback?
    var getCallbacks: GetCallbackStore
    var observeCallbacks: ObserveCallbackStore
    var functionCallbacks: FunctionCallbackStore
    
    var basedCClient: BasedCClientProtocol
    
    /// 32 bit integer representing the id of the c++ client
    var clientId: BasedClientId
    
    required init(
        cClient: BasedCClientProtocol = BasedCClient(),
        observeCallbacks: ObserveCallbackStore = ObserveCallbacks.shared,
        getCallbacks: GetCallbackStore = GetCallbacks.shared,
        functionCallbacks: FunctionCallbackStore = FunctionCallbacks.shared
    ) {
        self.basedCClient = cClient
        self.observeCallbacks = observeCallbacks
        self.getCallbacks = getCallbacks
        self.functionCallbacks = functionCallbacks
        clientId = basedCClient.create()
    }
    
    deinit {
        Task { [weak self] in
            guard let self = self else { return }
            await observeCallbacks.perform { id, callback in
                self.basedCClient.unobserve(clientId: self.clientId, subscriptionId: id)
            }
            self.basedCClient.delete(clientId)
        }
    }
    
    func auth(token: String, callback: @escaping AuthCallback) {
        authCallback = callback
        basedCClient.auth(clientId: clientId, token: token, callback: handleAuthCallback)
    }
    
    @Sendable
    func get(name: String, payload: String, callback: @escaping Callback) async {
        let id = basedCClient.get(clientId: clientId, name: name, payload: payload, callback: handleGetCallback)
        await getCallbacks.add(callback: callback, id: id)
    }
    
    func observe(name: String, payload: String, callback: @escaping ObserveCallback) async -> ObserveId {
        let id = basedCClient.observe(clientId: clientId, name: name, payload: payload, callback: handleObserveCallback)
        await observeCallbacks.add(callback: callback, id: id)
        dataInfo("OBSERVE \(id)")
        return id
    }
    
    func unobserve(observeId: ObserveId) async {
        dataInfo("UNOBSERVE \(observeId)")
        basedCClient.unobserve(clientId: clientId, subscriptionId: observeId)
        await observeCallbacks.remove(id: observeId)
    }
    
    func function(name: String, payload: String, callback: @escaping Callback) async {
        let id = basedCClient.function(clientId: clientId, name: name, payload: payload, callback: handleFunctionCallback)
        await functionCallbacks.add(callback: callback, id: id)
    }
    
    func callbackHandler(with type: HandlerType) {
        switch type {
        case let .auth(data):
            authCallback?(data)
            authCallback = nil
        case let .function(id, data, error):
            Task { await callFunction(id: id, data: data, error: error) }
        case let .get(id, data, error):
            Task { await callGet(id: id, data: data, error: error) }
        case let .observe(id, data, checksum, error):
            Task { await callObserve(id: id, data: data, checksum: checksum, error: error) }
        }
    }
    
    @ObserveCallbacks
    private func callObserve(id: ObserveId, data: String, checksum: UInt64, error: String) {
        Task {
            await observeCallbacks.fetch(id: id)?(data, checksum, error, id)
        }
    }
    
    @FunctionCallbacks
    private func callFunction(id: CallbackId, data: String, error: String) {
        Task {
            await functionCallbacks.fetch(id: id)?(data, error)
            await functionCallbacks.remove(id: id)
        }
    }
    
    @GetCallbacks
    private func callGet(id: CallbackId, data: String, error: String) {
        Task {
            await getCallbacks.fetch(id: id)?(data, error)
            await getCallbacks.remove(id: id)
        }
    }
    
}

extension BasedClient {
    static let `default`: BasedClient = .init()
}
