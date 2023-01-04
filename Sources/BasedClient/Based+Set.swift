//
//  Based+Set.swift
//  
//
//  Created by Alexander van der Werff on 18/01/2022.
//

import Foundation
import NakedJson

extension Based {
    
    public func set(
        query: Query
    ) async throws -> String? {
        let queryString = query.jsonStringify()
        do {
            let result: [String: String] = try await function(name: "based-db-set", payload: queryString)
            return result["id"]
        } catch {
            throw error
        }
    }
    
}
