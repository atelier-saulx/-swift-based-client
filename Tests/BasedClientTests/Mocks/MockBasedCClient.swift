//
//  File.swift
//  
//
//  Created by Alexander van der Werff on 27/12/2022.
//

import Foundation
@testable import BasedClient

class MockBasedCClient: BasedCClientProtocol {
    func create() -> Int32 {
        1
    }
    
    func delete(_ clientId: BasedClientID) {}
    
    func connect(clientId: BasedClientID, url: String) {}
    
    func connect(clientId: BasedClientID, cluster: String, org: String, project: String, env: String, name: String, key: String, optionalKey: Bool) {}
    
    func disconnect(clientId: BasedClientID) {}
    
    func auth(clientId: BasedClientID, token: String, callback: @convention(c) (UnsafePointer<CChar>) -> Void) {
        Current.basedClient.callbackHandler(with: .auth(data: "{\"data\": true}"))
    }
    
    var getCallbackParam: (data: UnsafeMutablePointer<CChar>, error: UnsafeMutablePointer<CChar>, subscriptionId: CInt)?
    func get(clientId: BasedClientID, name: String, payload: String, callback: @convention(c) (UnsafePointer<CChar>, UnsafePointer<CChar>, CInt) -> Void) -> CInt {
        let data = (getCallbackParam?.0)!
        let error = (getCallbackParam?.1)!
        let id = (getCallbackParam?.2)!
        Task.detached {
            try await Task.sleep(seconds: 0.5)
            callback(data, error, id)
        }
        
        return id
    }
    
    func function(clientId: BasedClientID, name: String, payload: String, callback: @convention(c) (UnsafePointer<CChar>, UnsafePointer<CChar>, CInt) -> Void) -> CInt {
        1
    }
    
    func service(clientId: BasedClientID, cluster: String, org: String, project: String, env: String, name: String, key: String, optionalKey: Bool) -> String {
        ""
    }
    
    func observe(clientId: BasedClientID, name: String, payload: String, callback: @convention(c) (UnsafePointer<CChar>, UInt64, UnsafePointer<CChar>, CInt) -> Void) -> CInt {
        1
    }
    
    func unobserve(clientId: BasedClientID, subscriptionId subId: CInt) {
        
    }
    
    
}
