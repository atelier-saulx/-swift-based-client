//
//  BasedWrapper.swift
//  
//
//  Created by Alexander van der Werff on 21/12/2022.
//

import Foundation
@_exported import BasedOBJCWrapper

/// Client id returned from a Based C++ Client
typealias BasedClientId = Int32

struct BasedClientWrapper {
    let createClient: () -> BasedClientId
    let connectUrl: (_ id: BasedClientId, _ urlString: String) -> ()
    let connect: (_ id: BasedClientId, _ cluster: String, _ org: String, _ project: String, _ env: String, _ name: String, _ key: String, _ optionalKey: Bool) -> ()
    let disconnect: (_ id: BasedClientId) -> ()
    let deleteClient: (_ id: BasedClientId) -> ()
    let unobserve: (_ id: BasedClientId, _ observeId: ObserveId) -> ()
    let get: (_ id: BasedClientId, _ name: String, _ payload: String) -> Int32
    let observe: (_ id: BasedClientId, _ name: String, _ payload: String) -> Int32
    let function: (_ id: BasedClientId, _ name: String, _ payload: String) -> Int32
    let auth: (_ id: BasedClientId, _ token: String) -> ()
}
//
extension BasedClientWrapper {
    static let `default` = Self (
        createClient: {
            BasedCClient.create()
        },
        connectUrl: { clientId, urlString in
            BasedCClient.connect(clientId: clientId, url: urlString)
        },
        connect: { clientId, cluster, org, project, env, name, key, optionalKey in
            BasedCClient.connect(clientId: clientId, cluster: cluster, org: org, project: project, env: env, name: name, key: key, optionalKey: optionalKey)
        },
        disconnect: { clientId in
            BasedCClient.disconnect(clientId: clientId)
        },
        deleteClient: { clientId in
            BasedCClient.delete(clientId)
        },
        unobserve: { clientId, observeId in
            BasedCClient.unobserve(clientId: clientId, subscriptionId: observeId)
        },
        get: { clientId, name, payload in
            ///handleGetCallback needs to be global for C interopt
            BasedCClient.get(clientId: clientId, name: name, payload: payload, callback: handleGetCallback)
        },
        observe: { clientId, name, payload in
            ///handleObservableCallback needs to be global for C interopt
            BasedCClient.observe(clientId: clientId, name: name, payload: payload, callback: handleObservableCallback)
        },
        function: { clientId, name, payload in
            ///handleFunctionCallback needs to be global for C interopt
            BasedCClient.function(clientId: clientId, name: name, payload: payload, callback: handleFunctionCallback)
        },
        auth: { clientId, token in
            ///handleAuth needs to be global for C interopt
            BasedCClient.auth(clientId: clientId, token: token, callback: handleAuth)
        }
    )
}
