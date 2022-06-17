//
//  Based+Call.swift
//  
//
//  Created by Alexander van der Werff on 16/01/2022.
//

import Foundation
import NakedJson

extension Based {

    public func call<Payload: Encodable, Result: Decodable>(name: String, payload: Payload) async throws -> Result {
        let encoder = NakedJsonEncoder()
        let payload = try encoder.encode(payload)
        let data = try await _call(name: name, payload: payload)
        return try decoder.decode(Result.self, from: data)
    }
    
    public func call<T: Decodable>(name: String, payload: Json = [:]) async throws -> T {
        let data = try await _call(name: name, payload: payload)
        return try decoder.decode(T.self, from: data)
    }
    
    private func _call(name: String, payload: Json) async throws -> Data {
        try await withCheckedThrowingContinuation { continuation in
            addRequest(type: .call, payload: payload, continuation: continuation, name: name)
        }
    }
    
}
