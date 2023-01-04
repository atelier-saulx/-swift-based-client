//
//  BasedClientProtocol.swift
//  
//
//  Created by Alexander van der Werff on 20/12/2022.
//

import Foundation
@_exported import BasedOBJCWrapper

typealias ObserveCallbackStore = CallbacksStore<ObserveId, ObserveCallback>
typealias GetCallbackStore = CallbacksStore<CallbackId, Callback>
typealias FunctionCallbackStore = CallbacksStore<CallbackId, Callback>

protocol BasedClientProtocol {
    /// Client Id
    var clientId: BasedClientId { get set }
    /// Auth callbacks
    var authCallback: AuthCallback? { get set }
    /// Get callbacks
    var getCallbacks: GetCallbackStore { get set }
    /// Observe callbacks
    var observeCallbacks: ObserveCallbackStore { get set }
    /// Function callbacks
    var functionCallbacks: FunctionCallbackStore { get set }
    /// Based C client
    var basedCClient: BasedCClientProtocol { get set }
     
    /// Handles calback from c++ client
    func callbackHandler(with type: HandlerType)
    
    /// Connects a client to Based
    /// - Parameters: String representing an url to connect with
    func connect(urlString: String)
    
    /// Connects a client with a set of params
    /// - Parameters:
    ///     - cluster: String
    ///     - org: String
    func connect(
        cluster: String,
        org: String,
        project: String,
        env: String,
        name: String,
        key: String,
        optionalKey: Bool
    )
    
    /// Disconnects the client with id
    func disconnect()
    
    /// Deletes the current client with id
    func deleteClient()
    
    /// Authenticate
    ///  - Parameters
    ///     - token: JWT Token
    ///     - callback: called when server returns data
    func auth(token: String, callback: @escaping AuthCallback)
    
    /// Get
    ///  - parameters
    ///     - name: name of function
    ///     - payload: as a valid json string
    ///     - callback: called when server returns data
    func get(name: String, payload: String, callback: @escaping Callback) async
    
    /// Observe
    ///  - parameters
    ///     - name: name of function
    ///     - payload: as a valid json string
    ///     - callback: callback that the observable will trigger.
    ///     - returns subscription id
    func observe(name: String, payload: String, callback: @escaping ObserveCallback) async -> CInt
    
    /// Unobserve
    ///  - parameters
    ///     - observeId: Id returned from calling observe
    func unobserve(observeId: CInt) async
    
    /// Based client function calls
    ///  - parameters
    ///     - name: name of function
    ///     - payload: as a valid json string
    ///     - callback: called when server returns data
    func `function`(name: String, payload: String, callback: @escaping Callback) async
    
    /// Service
    /// - Parameters:
    ///     - cluster:
    ///     - org:
    ///     - project:
    ///     - env:
    ///     - name:
    ///     - key:
    ///     - optionalKey:
    func service(
        cluster: String,
        org: String,
        project: String,
        env: String,
        name: String,
        key: String,
        optionalKey: Bool
    ) -> String
    
    /// Based client init
    ///  - parameters
    ///     - cclient: C client conforming BasedCClientProtocol
    ///     - observeCallbacks: Data structure for storing callbacks
    init(
        cClient: BasedCClientProtocol,
        observeCallbacks: ObserveCallbackStore,
        getCallbacks: GetCallbackStore,
        functionCallbacks: FunctionCallbackStore
    )
}
