//
//  Based+Schema.swift
//  
//
//  Created by Alexander van der Werff on 13/02/2022.
//

import Foundation
import NakedJson

extension Based {
    
    public func schema() async throws -> Json {
        let data = try await _schema()
        let schema = try decoder.decode(Json.self, from: data)
        return schema
    }
    
    private func _schema() async throws -> Data {
        try await withCheckedThrowingContinuation { continuation in
            addRequest(type: .getConfiguration, payload: 0, continuation: continuation, name: "")
        }
    }
    
    public func configure(schema: Json) async throws -> Json {
        let data = try await _configure(payload: ["schema": schema])
        let schema = try decoder.decode(Json.self, from: data)
        return schema
    }
    
    private func _configure(payload: Json) async throws -> Data {
        try await withCheckedThrowingContinuation { continuation in
            addRequest(type: .configuration, payload: payload, continuation: continuation, name: "")
        }
    }
    
}
