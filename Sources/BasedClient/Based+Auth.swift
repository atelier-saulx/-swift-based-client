//
//  Based+Auth.swift
//  
//
//  Created by Alexander van der Werff on 16/01/2022.
//

import Foundation
import NakedJson

public struct AuthState: JsonConvertible, Decodable {
    
    public let token: String?
    public let userId: String?
    public let refreshToken: String?
    public let error: String?
    public let persistent: Bool?
    public let type: String?
    
    public init(
        token: String? = nil,
        userId: String? = nil,
        refreshToken: String? = nil,
        error: String? = nil,
        persistent: Bool? = nil,
        type: String? = nil
    ) {
        self.token = token
        self.userId = userId
        self.refreshToken = refreshToken
        self.error = error
        self.persistent = persistent
        self.type = type
    }
    
    public func asJson() throws -> Json {
        var tuples = [String: Json]()
        if let token = token {
            tuples["token"] = .string(token)
        }
        if let userId {
            tuples["userId"] = .string(userId)
        }
        if let refreshToken {
            tuples["refreshToken"] = .string(refreshToken)
        }
        if let error {
            tuples["error"] = .string(error)
        }
        if let persistent {
            tuples["persistent"] = .bool(persistent)
        }
        if let type {
            tuples["type"] = .string(type)
        }
        return Json.object(tuples)
    }
}

extension Based {
    
    
    /// Authorize user with token
    /// - Parameters:
    /// - authState: AuthState
    /// - Returns: Result of authorization
    ///
    /// If you send an empty string token, sdk will deauthorize user
    @discardableResult
    public func set(authState: AuthState) async -> AuthState {
        let json = try? authState.asJson()
        return await withCheckedContinuation { continuation in
            Current.basedClient.auth(token: json?.description ?? "{}") { [decoder] data in
                guard
                    let data = data.data(using: .utf8),
                    let result = try? decoder.decode(AuthState.self, from: data)
                else {
                    continuation.resume(returning: AuthState()) //should not occur
                    return
                }
                continuation.resume(returning: result)
            }
        }
    }
    
    /**
     Sign out the user and remove the auth token.
     
     - Returns:
        An empty AuthState value
     */
    @discardableResult
    public func clearAuth() async -> AuthState {
        return await withCheckedContinuation { continuation in
            Current.basedClient.auth(token: "{}") { [decoder] data in
                guard
                    let data = data.data(using: .utf8),
                    let result = try? decoder.decode(AuthState.self, from: data)
                else {
                    continuation.resume(returning: AuthState())
                    return
                }
                continuation.resume(returning: result)
            }
        }
    }
}

