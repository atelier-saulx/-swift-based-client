//
//  Based+Auth.swift
//  
//
//  Created by Alexander van der Werff on 16/01/2022.
//

import Foundation
import NakedJson

extension Based {
    
    
    /// Authorize user with token
    /// - Parameters:
    ///   - token: token to be used for auth
    /// - Returns: Result of authorization
    ///
    /// If you send an empty string token, sdk will deauthorize user
    @discardableResult
    public func signIn(token: String) async -> Bool {
        return await withCheckedContinuation { continuation in
            Current.basedClient.auth(token: token) { [decoder] data in
                guard
                    let data = data.data(using: .utf8),
                    let result = try? decoder.decode(Bool.self, from: data)
                else {
                    continuation.resume(returning: false)
                    return
                }
                continuation.resume(returning: result)
            }
        }
    }
    
    /// Sign out
    @discardableResult
    public func signOut() async -> Bool {
        return await withCheckedContinuation { continuation in
            Current.basedClient.auth(token: "") { [decoder] data in
                guard
                    let data = data.data(using: .utf8),
                    let result = try? decoder.decode(Bool.self, from: data)
                else {
                    continuation.resume(returning: false)
                    return
                }
                continuation.resume(returning: result)
            }
        }
    }
}

