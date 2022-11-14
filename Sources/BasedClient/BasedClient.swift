//
//  File.swift
//  
//
//  Created by Alexander van der Werff on 11/11/2022.
//

import Foundation
@_exported import BasedOBJCWrapper

public typealias BasedClientId = Int32

public struct BasedClient {
    
    private let clientId = BasedWrapper.basedClient()
    public static let clusterUrl = "https://d15p61sp2f2oaj.cloudfront.net/"
    
    public init() {}
    
    public func deleteClient(clientId: BasedClientId) {
        BasedWrapper.deleteClient(clientId)
    }
    
    public func connect(with url: String) {
        BasedWrapper.connect(clientId: clientId, url: url)
    }
    
    public func connect(
        cluster: String = Self.clusterUrl,
        org: String,
        project: String,
        env: String,
        name: String = "@based/edge",
        key: String = "",
        optionalKey: Bool = false
    ) {
        BasedWrapper.connect(clientId: clientId, cluster: cluster, org: org, project: project, env: env, name: name, key: key, optionalKey: optionalKey)
    }

    
    public func auth(token: String) {
            
        BasedWrapper.auth(clientId: clientId, token: "s") { [clientId] chars in
            print(chars)
        }
    }

}
