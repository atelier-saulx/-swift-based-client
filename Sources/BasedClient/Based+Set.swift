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
        let data = try await _set(query: query)
        let set = try decoder.decode([String: String].self, from: data)
        return set["id"]
    }
    
    private func _set(query: Query) async throws -> Data {
        try await withCheckedThrowingContinuation { continuation in
            let payload = Json.object(query.dictionary())
            addRequest(type: .set, payload: payload, continuation: continuation, name: "")
        }
    }
    
}
