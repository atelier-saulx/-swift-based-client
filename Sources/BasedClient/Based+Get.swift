//
//  Based+Get.swift
//  
//
//  Created by Alexander van der Werff on 16/01/2022.
//

import Foundation
import NakedJson

extension Based {
    
    public func get<Result: Decodable>(name: String, payload: Json = [:]) async throws -> Result {
        try await withCheckedThrowingContinuation { [weak self] continuation in
            guard let self = self
            else {
                continuation.resume(throwing: BasedError.other(message: "Function could not complete"))
                return
            }
            do {
                let payload = try self.jsonEncoder.encode(payload)
                Task {
                    await Current.basedClient.get(name: name, payload: payload.description) { dataString, errorString in
                        guard
                            let data = dataString.data(using: .utf8),
                            errorString.isEmpty
                        else {
                            
                            let error = BasedError.from(errorString)
                            continuation.resume(throwing: error)
                            return
                        }
                        do {
                            let value = try self.decoder.decode(Result.self, from: data)
                            continuation.resume(returning: value)
                        } catch {
                            continuation.resume(throwing: error)
                        }
                    }
                }
            } catch {
                continuation.resume(throwing: error)
            }
        }
    }
    
    public func get<Result: Decodable>(query: Query) async throws -> Result {
        let queryString = query.jsonStringify()
        return try await function(name: "based-db-get", payload: queryString)
    }
    
}
