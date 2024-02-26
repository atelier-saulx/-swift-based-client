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
struct ObserveCallbacks {
    static var shared: CallbacksStore<ObserveId, ObserveCallback> = .init()
}

/// Get callback store
struct GetCallbacks {
    static var shared: CallbacksStore<CallbackId, Callback> = .init()
}

/// Get callback store
struct FunctionCallbacks {
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
    dataInfo(#function)
    let dataString = String(cString: data)
    let errorString = String(cString: error)
    Current.basedClient.callbackHandler(with: .observe(id: observeId, data: dataString, checksum: checksum, error: errorString))
}

final class BasedClient: BasedClientProtocol {
    
    private let getQueue = DispatchQueue(label: "com.based.client.get", attributes: .concurrent)
    private let getSemaphore = DispatchSemaphore(value: 1)
    private let callGetQueue = DispatchQueue(label: "com.based.client.call.get", attributes: .concurrent)
    private let callGetSemaphore = DispatchSemaphore(value: 1)
    
    private let functionQueue = DispatchQueue(label: "com.based.client.function", attributes: .concurrent)
    private let functionSemaphore = DispatchSemaphore(value: 1)
    private let callFunctionQueue = DispatchQueue(label: "com.based.client.call.function", attributes: .concurrent)
    private let callFunctionSemaphore = DispatchSemaphore(value: 1)
    
    private let observeQueue = DispatchQueue(label: "com.based.client.observe", attributes: .concurrent)
    private let observeSemaphore = DispatchSemaphore(value: 0)
    private let callObserveQueue = DispatchQueue(label: "com.based.client.call.observe", attributes: .concurrent)
    private let callObserveSemaphore = DispatchSemaphore(value: 1)

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
        observeCallbacks.perform { id, callback in
            self.basedCClient.unobserve(clientId: self.clientId, subscriptionId: id)
        }
        self.basedCClient.delete(clientId)
    }
    
    func auth(token: String, callback: @escaping AuthCallback) {
        authCallback = callback
        basedCClient.auth(clientId: clientId, token: token, callback: handleAuthCallback)
    }
    
    func get(name: String, payload: String, callback: @escaping Callback) {
        getQueue.async { [weak self] in
            guard let self else { return }
            getSemaphore.wait()
            let id = basedCClient.get(clientId: clientId, name: name, payload: payload, callback: handleGetCallback)
            getCallbacks.add(callback: callback, id: id)
            getSemaphore.signal()
        }
    }
    
    func observe(name: String, payload: String, callback: @escaping ObserveCallback) throws -> ObserveId {
        var id: ObserveId?
        observeQueue.async { [weak self] in
            guard let self else { return }
            dataInfo("observeQueue: ", name)
            let observeId = basedCClient.observe(clientId: clientId, name: name, payload: payload, callback: handleObserveCallback)
            observeCallbacks.add(callback: callback, id: observeId)
            id = observeId
            observeSemaphore.signal()
        }
        observeSemaphore.wait()
        guard let id = id else { throw BasedError.other(message: "Observe failed") }
        dataInfo("OBSERVE \(id)")
        return id
    }
    
    func unobserve(observeId: ObserveId) {
        dataInfo("UNOBSERVE \(observeId)")
        basedCClient.unobserve(clientId: clientId, subscriptionId: observeId)
        observeCallbacks.remove(id: observeId)
    }
    
    func function(name: String, payload: String, callback: @escaping Callback) {
        functionQueue.async { [weak self] in
            guard let self else { return }
            functionSemaphore.wait()
            let id = basedCClient.function(clientId: clientId, name: name, payload: payload, callback: handleFunctionCallback)
            functionCallbacks.add(callback: callback, id: id)
            functionSemaphore.signal()
        }
    }
    
    func callbackHandler(with type: HandlerType) {
        switch type {
        case let .auth(data):
            authCallback?(data)
            authCallback = nil
        case let .function(id, data, error):
            callFunction(id: id, data: data, error: error)
        case let .get(id, data, error):
            callGet(id: id, data: data, error: error)
        case let .observe(id, data, checksum, error):
            callObserve(id: id, data: data, checksum: checksum, error: error)
        }
    }
    
    private func callObserve(id: ObserveId, data: String, checksum: UInt64, error: String) {
        callObserveQueue.async { [weak self] in
            guard let self else { return }
            callObserveSemaphore.wait()
            observeCallbacks.fetch(id: id)?(data, checksum, error, id)
            callObserveSemaphore.signal()
        }
    }
    
    private func callFunction(id: CallbackId, data: String, error: String) {
        callFunctionQueue.async { [weak self] in
            guard let self else { return }
            callFunctionSemaphore.wait()
            functionCallbacks.fetch(id: id)?(data, error)
            functionCallbacks.remove(id: id)
            callFunctionSemaphore.signal()
        }
    }
    
    private func callGet(id: CallbackId, data: String, error: String) {
        callGetQueue.async { [weak self] in
            guard let self else { return }
            callGetSemaphore.wait()
            getCallbacks.fetch(id: id)?(data, error)
            getCallbacks.remove(id: id)
            callGetSemaphore.signal()
        }
    }
    
}

extension BasedClient {
    static let `default`: BasedClient = .init()
}
