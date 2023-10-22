//
//  Based+Set.swift
//  
//
//  Created by Alexander van der Werff on 18/01/2022.
//

import Foundation
import NakedJson

extension Based {
    
    /**
     * Sets a query in the database.
     *
     * - Parameters:
     *   - query: The query to set in the database.
     * - Returns:
     *      The id of the set query as a string, or nil if the operation fails.
     * - Throws:
     *      An error if the operation fails.
     */
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
