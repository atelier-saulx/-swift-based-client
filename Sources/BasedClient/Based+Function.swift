//
//  Based+Call.swift
//  
//
//  Created by Alexander van der Werff on 16/01/2022.
//

import Foundation
import NakedJson

extension Based {

    /**
     Execute a specific function with a given payload and returns the result.
     
     - Parameters:
        - name: A string representing the name of the function to execute.
        - payload: An object conforming to the Encodable protocol, representing the payload to be sent with the function request. Default value is nil.
     
     - Returns:
        A Result object conforming to the Decodable protocol, representing the result of the function execution.
     
     - Throws:
        BasedError
   
     */
    public func function<Payload: Encodable, Result: Decodable>(name: String, payload: Payload? = nil) async throws -> Result {
        do {
            var payloadString = ""
            if let payload = payload {
                let payloadEncoded = try jsonEncoder.encode(payload)
                payloadString = payloadEncoded.description
            }
            return try await function(name: name, payload: payloadString)
        } catch {
            throw error
        }
    }
    
    func function<Result: Decodable>(name: String, payload: String) async throws -> Result {
        try await withCheckedThrowingContinuation { [weak self] continuation in
            guard let self = self
            else {
                continuation.resume(throwing: BasedError.other(message: "Function could not complete"))
                return
            }
            Task {
                await Current.basedClient.function(name: name, payload: payload) { dataString, errorString in
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
        }
    }
}
