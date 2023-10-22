//
//  Based+Schema.swift
//  
//
//  Created by Alexander van der Werff on 13/02/2022.
//

import Foundation
import NakedJson

extension Based {
    
    /// Fetch current schema
    public func schema() async throws -> Json {
        return try await function(name: "based-db-observe-schema", payload: "")
    }
    
    /// Update schema
    public func update(schema: Json) async throws -> Json {
        return try await function(name: "based-db-update-schema", payload: ["schema": schema])
    }
    
}
