//
//  BasedClient.swift
//  
//
//  Created by Alexander van der Werff on 11/11/2022.
//

import Foundation
@_exported import BasedOBJCWrapper

/// Internal types
/// Callback id present in get callbacks and function callbacks
typealias CallbackId = Int32
/// Observe id present in subscription callbacks
typealias ObserveId = Int32
/// Get or Function callback
typealias Callback = (_ data: String, _ error: String) -> ()
/// Observe callback
typealias ObserveCallback = (_ data: String, _ checksum: UInt64, _ error: String, _ observeId: ObserveId) -> ()
/// Auth callback
typealias AuthCallback = (_ data: String) -> ()

/// Safe observe callback store
actor ObserveCallbacks {
    var callbacks: [ObserveId: ObserveCallback] = [:]
    func add(callback: @escaping ObserveCallback, id: ObserveId) {
        callbacks[id] = callback
    }
    func fetch(id: ObserveId) -> ObserveCallback? {
        callbacks[id]
    }
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
func handleAuth(data: UnsafePointer<CChar>) {
    let dataString = String(cString: data)
    dataInfo("AUTH DATA:: \(dataString)")
    guard dataString.isEmpty == false else { return }
    Based.client.callbackHandler(with: .auth(data: dataString))
}

/// Callback get handler
/// Dealing with c pointer functions forces a global approach
func handleGetCallback(data: UnsafePointer<CChar>, error: UnsafePointer<CChar>, subscriptionId: Int32) {
    let dataString = String(cString: data)
    let errorString = String(cString: error)
    dataInfo("GET DATA:: \(dataString), ERROR:: \(errorString)")
    Based.client.callbackHandler(with: .get(id: subscriptionId, data: dataString, error: errorString))
}

/// Callback function handler
func handleFunctionCallback(data: UnsafePointer<CChar>, error: UnsafePointer<CChar>, subscriptionId: Int32) {
    let dataString = String(cString: data)
    let errorString = String(cString: error)
    dataInfo("FUNC DATA:: \(dataString), ERROR:: \(errorString)")
    Based.client.callbackHandler(with: .function(id: subscriptionId, data: dataString, error: errorString))
}

/// Observe callback handler
func handleObservableCallback(data: UnsafePointer<CChar>, checksum: UInt64, error: UnsafePointer<CChar>, observeId: Int32) {
    let dataString = String(cString: data)
    let errorString = String(cString: error)
    dataInfo("OBSERVE DATA:: \(dataString), ERROR:: \(errorString)")
    Based.client.callbackHandler(with: .observe(id: observeId, data: dataString, checksum: checksum, error: errorString))
}

extension BasedClientProtocol {
    static func createClient() -> BasedClientId {
        Current.basedClientWrapper.createClient()
    }
    
    func connect(urlString: String) {
        Current.basedClientWrapper.connectUrl(clientId, urlString)
    }
    
    func connect(
        cluster: String = "https://d15p61sp2f2oaj.cloudfront.net/",
        org: String,
        project: String,
        env: String,
        name: String = "@based/edge",
        key: String = "",
        optionalKey: Bool = false
    ) {
        Current.basedClientWrapper.connect(clientId, cluster, org, project, env, name, key, optionalKey)
    }
    
    func disconnect() {
        Current.basedClientWrapper.disconnect(clientId)
    }
    
    func deleteClient() {
        Current.basedClientWrapper.deleteClient(clientId)
    }
    
    func unobserve(observeId: Int32) {
        Current.basedClientWrapper.unobserve(clientId, observeId)
    }
    
}

public class BasedClient: BasedClientProtocol {
    
    var authCallback: AuthCallback?
    var callbacks: [Int32: Callback] = [:]
    var observeCallbacks: ObserveCallbacks = ObserveCallbacks()
    var functions: [Int32: Callback] = [:]
    
    var clientId: BasedClientId
    
    init() {
        clientId = Self.createClient()
    }
    
    func auth(token: String, callback: @escaping AuthCallback) {
        authCallback = callback
        Current.basedClientWrapper.auth(clientId, token)
    }
    
    func get(name: String, payload: String, callback: @escaping Callback) {
        let id = Current.basedClientWrapper.get(clientId, name, payload)
        callbacks[id] = callback
    }
    
    func observe(name: String, payload: String, callback: @escaping ObserveCallback) async {
        let id = Current.basedClientWrapper.observe(clientId, name, payload)
        await observeCallbacks.add(callback: callback, id: id)
    }
    
    func function(name: String, payload: String, callback: @escaping Callback) {
        let id = Current.basedClientWrapper.function(clientId, name, payload)
        functions[id] = callback
    }
    
    func callbackHandler(with type: HandlerType) {
        switch type {
        case let .auth(data):
            authCallback?(data)
            authCallback = nil
        case let .function(id, data, error):
            functions[id]?(data, error)
            functions.removeValue(forKey: id)
        case let .get(id, data, error):
            callbacks[id]?(data, error)
            callbacks.removeValue(forKey: id)
        case let .observe(id, data, checksum, error):
            Task { [weak self] in await self?.observeCallbacks.fetch(id: id)?(data, checksum, error, id) }
        }
    }
    
}
