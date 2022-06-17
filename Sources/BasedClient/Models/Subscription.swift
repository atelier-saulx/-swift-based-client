//
//  Subscription.swift
//  
//
//  Created by Alexander van der Werff on 31/08/2021.
//

import Foundation
import NakedJson

public typealias SubscriptionId = Int
public typealias SubscriberId = String
typealias Subscriptions = Dictionary<SubscriptionId, SubscriptionModel>

actor SubscriptionManager {
    private var subscriptions = Subscriptions()
    
    func getSubscriptions() -> Subscriptions {
        return subscriptions
    }
    
    func subscription(with id: SubscriptionId) -> SubscriptionModel? {
        return subscriptions[id]
    }
    
    func removeSubscription(with id: SubscriptionId) {
        subscriptions.removeValue(forKey: id)
    }
    
    func updateSubscription(with id: SubscriptionId, subscription: SubscriptionModel) {
        subscriptions[id] = subscription
    }
    
    @discardableResult
    func addSubscriber(for id: SubscriptionId, and subscriber: SubscriptionCallback) -> SubscriberId {
        let subscriberId = UUID().uuidString
        subscriptions[id]?.subscribers[subscriberId] = subscriber
        return subscriberId
    }
}

struct SubscriptionModel {
    var error: BasedError?
    var payload: Json = nil
    let name: String?
    var subscribers: Dictionary<SubscriberId, SubscriptionCallback> = [:]
}

struct SubscriptionCallback {
    var onError: ErrorCallback?
    var onData: DataCallback?
}

enum SubscriptionType {
    case query(Query), `func`(_ name: String, _ payload: Json)
    
    func generateSubscriptionId() -> Int {
        switch self {
        case .query(let query):
            let json = Json.object(query.dictionary())
            return Current.hasher.hashObjectIgnoreKeyOrder(json)
        case let .func(name, payload):
            return Current.hasher.hashObjectIgnoreKeyOrder(["\(name)", payload])
        }
    }
}
