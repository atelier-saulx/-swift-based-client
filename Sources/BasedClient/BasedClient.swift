//
//  File.swift
//  
//
//  Created by Alexander van der Werff on 11/11/2022.
//

import Foundation
@_exported import BasedOBJCWrapper

public protocol BasedClientProtocol {
    func createClient() -> BasedClientId
    func connect(clientId: BasedClientId, urlString: String)
    func connect(
        clientId: BasedClientId,
        cluster: String,
        org: String,
        project: String,
        env: String,
        name: String,
        key: String,
        optionalKey: Bool
    )
    func deleteClient(clientId: BasedClientId)
    func auth(clientId: BasedClientId, token: String) async -> String?
}

extension BasedClientProtocol {
    public func createClient() -> BasedClientId {
        BasedWrapper.basedClient()
    }
    
    public func connect(clientId: BasedClientId, urlString: String) {
        BasedWrapper.connect(clientId: clientId, url: urlString)
    }
    
    public func connect(
        clientId: BasedClientId,
        cluster: String = "https://d15p61sp2f2oaj.cloudfront.net/",
        org: String,
        project: String,
        env: String,
        name: String = "@based/edge",
        key: String = "",
        optionalKey: Bool = false
    ) {
        BasedWrapper.connect(clientId: clientId, cluster: cluster, org: org, project: project, env: env, name: name, key: key, optionalKey: optionalKey)
    }
    
    public func deleteClient(clientId: BasedClientId) {
        BasedWrapper.deleteClient(clientId)
    }
    
    public func auth(clientId: BasedClientId, token: String) async -> String? {
        
//        return await withCheckedContinuation { continuation in
//            BasedWrapper.auth(clientId: clientId, token: token) { chars in
//                let string = String(cString: chars, encoding: .utf8)
//                continuation.resume(returning: string)
//            }
//        }
        return nil
    }
    
    public func f() async -> String {
        return await withCheckedContinuation { continuation in
            BasedWrapper.auth2(1, withName: "") { string in
                continuation.resume(returning: string)
            }
        }
    }
    
}

//func bridge<T : AnyObject>(obj : T) -> UnsafeRawPointer {
//    return UnsafeRawPointer(Unmanaged.passUnretained(obj).toOpaque())
//}
//
//func bridge<T : AnyObject>(ptr : UnsafeRawPointer) -> T {
//    return Unmanaged<T>.fromOpaque(ptr).takeUnretainedValue()
//}
//
//func bridgeRetained<T : AnyObject>(obj : T) -> UnsafeRawPointer {
//    return UnsafeRawPointer(Unmanaged.passRetained(obj).toOpaque())
//}
//
//func bridgeTransfer<T : AnyObject>(ptr : UnsafeRawPointer) -> T {
//    return Unmanaged<T>.fromOpaque(ptr).takeRetainedValue()
//}

public typealias BasedClientId = Int32

public struct BasedClient: BasedClientProtocol {
    
    public init() {
        let client = createClient()
        connect(clientId: client, org: "airhub", project: "airhub", env: "edge")
    }

}
