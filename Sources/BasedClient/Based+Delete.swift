//
//  Based+Delete.swift
//  
//
//  Created by Alexander van der Werff on 19/01/2022.
//

import Foundation
import NakedJson


extension Based {
    
    public func delete(id: String, database: String? = nil) async throws -> Bool {
        var payloadObject = ["$id": Json.string(id)]
        if let database = database {
            payloadObject["db"] = Json.string(database)
        }
        let data = try await _delete(payload: Json.object(payloadObject))
        let deleted = try decoder.decode([String: Int].self, from: data)
        let isDeleted = deleted["isDeleted"] ?? 0
        return isDeleted == 1 ? true : false
    }
    
    private func _delete(payload: Json) async throws -> Data {
        try await withCheckedThrowingContinuation { continuation in
            addRequest(type: .delete, payload: payload, continuation: continuation, name: "")
        }
    }
    
}
