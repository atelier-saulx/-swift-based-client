//
//  Based+Delete.swift
//  
//
//  Created by Alexander van der Werff on 19/01/2022.
//

import Foundation
import NakedJson


extension Based {
    
    /// Deletes a node in Based
    ///
    /// Function Based name is: based-db-delete
    ///
    ///  - parameters
    ///     - id: Based id
    ///     - database: Based database name
    public func delete(id: String, database: String? = nil) async throws -> Bool {
        var payloadObject = ["$id": Json.string(id)]
        if let database = database {
            payloadObject["db"] = Json.string(database)
        }
        let result: [String: Int] = try await function(name: "based-db-delete", payload: Json.object(payloadObject))
        let isDeleted = result["isDeleted"] ?? 0
        return isDeleted == 1 ? true : false
    }
    
}
