//
//  Based+Token.swift
//  
//
//  Created by Alexander van der Werff on 27/11/2021.
//

import Foundation

extension Based {
    
    
    /// sendToken
    /// - Parameters:
    ///   - token:
    ///   - options:
    func sendToken(_ token: String? = nil, _ options: SendTokenOptions? = nil) async {
        
        let subscriptions = await subscriptionManager.getSubscriptions()
        
        beingAuth = true
        if let token = token {
            self.token = token
            self.sendTokenOptions = options
        } else {
            let toBeDeleted = await cache.all()
                .map { id, _ in id }
                .filter { subscriptions[$0] != nil }
            
            await cache.remove(ids: toBeDeleted)
            
            self.token = nil
            self.sendTokenOptions = nil
        }
        if socket.connected {
            let message = TokenMessage(token: token)
            let jsonData = try! JSONEncoder().encode(message)
            if let jsonString = String(data: jsonData, encoding: .utf8) {
                socket.send(message: .string(jsonString))
                socket.idleTimeout()
                Task { await sendAllSubscriptions(reAuth: true) }
            }
        }
    }
    
    
    ///
    /// - Parameter data:
    func logoutSubscriptions(_ data: [Int]) async {
        
        let subscriptions = await subscriptionManager.getSubscriptions()
        var toBeDeletedCache = [SubscriptionId]()
        
        for id in data {
            toBeDeletedCache.append(id)
            var subscription = subscriptions[id]
            let error = BasedError
                .authorization(
                    message: "Unauthorized request",
                    name: "observe \(subscription?.name ?? "")"
                )
            subscription?.error = error
            if let subscription = subscription {
                await subscriptionManager.updateSubscription(with: id, subscription: subscription)
            
                for (_, callback) in subscription.subscribers {
                    await callback.onError?(error)
                }
            }
        }
        
        await cache.remove(ids: toBeDeletedCache)
    }
}

public struct SendTokenOptions {
    public let isBasedUser: Bool
    
    public init(isBasedUser: Bool) {
        self.isBasedUser = isBasedUser
    }
}
