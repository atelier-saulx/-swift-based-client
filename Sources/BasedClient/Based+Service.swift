//
//  File.swift
//  
//
//  Created by Alexander van der Werff on 18/01/2022.
//

import Foundation

extension Based {

    public func service(
        html: Bool
    ) -> String {
        return Current.basedClient.service(
            cluster: configuration.cluster,
            org: configuration.org,
            project: configuration.project,
            env: configuration.env,
            name: configuration.name,
            key: configuration.key,
            optionalKey: configuration.optionalKey,
            html: html
        )
    }

}
