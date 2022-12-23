//
//  BasedClientProtocol.swift
//  
//
//  Created by Alexander van der Werff on 20/12/2022.
//

import Foundation

protocol BasedClientProtocol {
    /// Client Id
    var clientId: BasedClientId { get set }
    /// Auth callbacks
    var authCallback: AuthCallback? { get set }
    /// Get callbacks
    var callbacks: [CallbackId: Callback] { get set }
    /// Observe callbacks
    var observeCallbacks: ObserveCallbacks { get set }
    /// Function callbacks
    var functions: [CallbackId: Callback] { get set }
    
    /// Handles calback from c++ client
    func callbackHandler(with type: HandlerType)
    
    /// Creates a client
    /// - Returns: A 32 bit integer representing the id of the c++ client
    static func createClient() -> BasedClientId
    
    /// Connects a client to Based
    /// - Parameters: a String representing an url to connect with
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
    func get(name: String, payload: String, callback: @escaping Callback)
    
    /// Observe
    ///  - parameters
    ///     - name: name of function
    ///     - payload: as a valid json string
    ///     - callback: callback that the observable will trigger.
    func observe(name: String, payload: String, callback: @escaping ObserveCallback) async
    
    /// Unobserve
    ///  - parameters
    ///     - observeId: Id returned from calling observe
    func unobserve(observeId: Int32)
    
    /// Based function calls
    ///  - parameters
    ///     - name: name of function
    ///     - payload: as a valid json string
    ///     - callback: called when server returns data
    func `function`(name: String, payload: String, callback: @escaping Callback)
}
