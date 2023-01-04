//
//  BasedClientProtocol+Ext.swift
//  
//
//  Created by Alexander van der Werff on 01/01/2023.
//

import Foundation
@_exported import BasedOBJCWrapper

private let clusterUrlString = "https://d15p61sp2f2oaj.cloudfront.net/"

extension BasedClientProtocol {
    
    func connect(urlString: String) {
        basedCClient.connect(clientId: clientId, url: urlString)
    }
    
    func connect(
        cluster: String = clusterUrlString,
        org: String,
        project: String,
        env: String,
        name: String = "@based/edge",
        key: String = "",
        optionalKey: Bool = false
    ) {
        basedCClient.connect(clientId: clientId, cluster: cluster, org: org, project: project, env: env, name: name, key: key, optionalKey: optionalKey)
    }
    
    func disconnect() {
        basedCClient.disconnect(clientId: clientId)
    }
    
    func deleteClient() {
        basedCClient.delete(clientId)
    }
    
    func service(
        cluster: String = clusterUrlString,
        org: String,
        project: String,
        env: String,
        name: String = "@based/edge",
        key: String = "",
        optionalKey: Bool = false
    ) -> String {
        return basedCClient.service(clientId: clientId, cluster: cluster, org: org, project: project, env: env, name: name, key: key, optionalKey: optionalKey)
    }
}
