//
//  Based+Auth.swift
//  
//
//  Created by Alexander van der Werff on 16/01/2022.
//

import Foundation
import NakedJson

struct AuthFunction {
    let resolve: (Bool) -> Void
}

extension Based {
    
    
    /// Authorize user with token
    /// - Parameters:
    ///   - token: token to be used for auth
    ///   - options: specific options to be sent with token
    /// - Returns: Result of authorization
    ///
    /// If you send ``nil`` token, sdk will deauthorize user
    @discardableResult
    public func signIn(token: String, options: SendTokenOptions? = nil) async -> Bool {
        await sendToken(token, options)
        
        emitter.emit(type: .auth, token)
        
        return await withCheckedContinuation { continuation in
            auth.append(AuthFunction(resolve: continuation.resume))
        }
    }
    
    @discardableResult
    public func signOut() async -> Bool {
        await sendToken()
        
        emitter.emit(type: .auth, nil)
        
        return await withCheckedContinuation { continuation in
            auth.append(AuthFunction(resolve: continuation.resume))
        }
    }
}

