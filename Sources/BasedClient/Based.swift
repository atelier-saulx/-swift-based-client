//
//  Based.swift
//  
//
//  Created by Alexander van der Werff on 29/08/2021.
//

import Foundation
import NakedJson

//Built-in Based functions are:
//- based-db-observe, observable
//- based-db-observe-schema, observable
//- based-db-set, non-observable
//- based-db-get, non-observable
//- based-db-delete, non-observable
//- based-db-update-schema, non-observable

public final class Based {
    
    let configuration: BasedConfiguration
    
    let decoder = JSONDecoder()
    
    let encoder = JSONEncoder()
    
    let jsonEncoder = NakedJsonEncoder()
    
    public required init(configuration: BasedConfiguration) {
        self.configuration = configuration
        Current.basedClient.connect(
            cluster: configuration.cluster,
            org: configuration.org,
            project: configuration.project,
            env: configuration.env,
            name: configuration.name,
            key: configuration.key,
            optionalKey: configuration.optionalKey,
            host: configuration.host,
            discoveryUrl: configuration.discoveryUrl
        )
    }
}
