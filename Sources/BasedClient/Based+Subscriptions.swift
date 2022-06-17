//
//  Based+Subscriptions.swift
//  
//
//  Created by Alexander van der Werff on 13/09/2021.
//

import Foundation
import NakedJson

extension Based {
    
    
    /// Description
    /// - Parameter reAuth: reAuth description
    func sendAllSubscriptions(reAuth: Bool = false) async {
        
        let subscriptions = await subscriptionManager.getSubscriptions()
        for (subscriptionId, subscription) in subscriptions {

            if (reAuth && subscription.error == nil) {
              // delete subscrption.authError
              continue
            }

            var getInQ: Message?, queued: Message?, getIndex: Int = 0

            let subscriptionMessages = await messages.allSubscriptionMessages()
            
            for (index, message) in subscriptionMessages.enumerated() {
                if message.id == subscriptionId {
                    if message.requestType == .getSubscription {
                        getIndex = index
                        getInQ = message
                    } else if message.requestType == .subscription {
                        queued = message
                    }
                }
            }
            
            if (getInQ != nil && queued != nil) {
                print("GET IN Q AND SUB IN Q SHOULD BE IMPOSSIBLE")
            }

            let cache = await cache.fetch(with: subscriptionId)
            var x = false

            if getInQ != nil {
                var onlyGets = true
                for subscriber in subscription.subscribers {

                    if subscriber.value.onData != nil {
                        onlyGets = false
                        break
                    }
                }

                if onlyGets == true {
                  x = true
                } else {
                  await messages.removeSubscriptionMessage(at: getIndex)
                }

                if
                    let cacheChecksum = cache?.checksum,
                    let inQCheksum = getInQ?.checksum,
                    cacheChecksum != inQCheksum {
                        getInQ?.checksum = cache?.checksum
                }

            }
            
            if !x {
                if queued != nil {
                    if cache != nil && queued?.checksum != cache?.checksum {
                        queued?.checksum = cache?.checksum
                        if getInQ != nil, let subscribeMessage = queued as? SubscribeMessage {
                            queued = SubscribeMessage(id: subscribeMessage.id, payload: subscribeMessage.payload, checksum: subscribeMessage.checksum, requestMode: .sendDataBackWithSubscription, functionName: subscribeMessage.functionName)
                        }
                    }
                } else {
                    addToMessages(
                        SubscribeMessage(
                            id: subscriptionId,
                            payload: subscription.payload,
                            checksum: cache?.checksum != nil ? cache?.checksum : 0,
                            requestMode: getInQ != nil ? .sendDataBackWithSubscription : .dontSendBack,
                            functionName: subscription.name
                        )
                    )
                }
            }

        }
    }
    
    
    /// Description
    /// - Parameters:
    ///   - payload: payload description
    ///   - name: name description
    /// - Returns: description
    func generateSubscriptionId(payload: Json, name: String?) -> Int {
        var array = [payload]
        if let name = name {
            array.insert(.string(name), at: 0)
        }
        return Current.hasher.hashObjectIgnoreKeyOrder(.array(array))
    }
    

    
    /// Description
    /// - Parameters:
    ///   - payload: payload description
    ///   - onData: onData description
    ///   - onInitial: onInitial description
    ///   - onError: onError description
    ///   - subscriptionId: subscriptionId description
    ///   - name: name description
    /// - Returns: description
    func addSubscriber(
        payload: Json,
        onData: @escaping DataCallback,
        onError: ErrorCallback?,
        subscriptionId: SubscriptionId?,
        name: String?
    ) async -> (subscriptionId: SubscriptionId, subscriberId: SubscriberId) {
        
        let finalSubscriptionId =
            subscriptionId
            ??
            self.generateSubscriptionId(payload: payload, name: name)
        
        var subscription = await subscriptionManager.subscription(with: finalSubscriptionId)
        
        let cache = await cache.fetch(with: finalSubscriptionId)
        
        //let subscriberId: Int = (subscription?.subscribers.count ?? 0) + 1
        var subscriberId = ""
        
        if let sub = subscription {
            
            var onlyGets = true
            sub.subscribers.forEach { id, callback in
                if callback.onData != nil {
                    onlyGets = false
                }
            }
            
            subscriberId = await subscriptionManager
                .addSubscriber(
                    for: finalSubscriptionId,
                       and: SubscriptionCallback(onError: onError, onData: onData))
            
            if onlyGets {
                
                try? await messages.removeAllSubscriptionMessages { message in
                    message.requestType == .getSubscription && message.id == finalSubscriptionId
                }
                
                let message = SubscribeMessage(
                    id: finalSubscriptionId,
                    payload: payload,
                    checksum: cache?.checksum ?? 0,
                    requestMode: .sendDataBackWithSubscription,
                    functionName: name
                )
                
                addToMessages(message)
            }
            
        } else {
            
            subscription = SubscriptionModel(
                payload: payload,
                name: name,
                subscribers: [:]
            )
            
            await subscriptionManager.updateSubscription(with: finalSubscriptionId, subscription: subscription!)
            await subscriberId = subscriptionManager.addSubscriber(for: finalSubscriptionId, and: SubscriptionCallback(onError: onError, onData: onData))
            
            var dontSend = false
            var includeReply = false
            
            var messagesToDelete = [Message?]()
            var messageToUpdate = [Message?]()
            
            let subscriptionMessages = await messages.allSubscriptionMessages()
        
            var subsMsg: SubscribeMessage?
            subscriptionMessages.forEach { message in
                let type = message.requestType
                let id = message.id
                let checksum = message.checksum
                
                if
                    (type == .unsubscribe || type == .sendSubscriptionData || type == .getSubscription)
                        && id == finalSubscriptionId {
                    if type == .getSubscription {
                        includeReply = true
                    }
                    subsMsg?.requestMode = .sendDataBackWithSubscription
                    messagesToDelete.append(subsMsg)
                    messageToUpdate.removeAll { mes in
                        mes?.id == subsMsg?.id
                    }
                    
                } else if type == .subscription && id == finalSubscriptionId {
                    dontSend = true
                    
                    subsMsg = message
                    
                    var messageIsChanged = false
                    if checksum != cache?.checksum {
                        subsMsg?.checksum = cache?.checksum
                        messageIsChanged = true
                    }
                    if subsMsg?.requestMode != nil && includeReply {
                        subsMsg?.requestMode = .sendDataBackWithSubscription
                        messageIsChanged = true
                    }
                    
                    if messageIsChanged == true {
                        messageToUpdate.append(subsMsg)
                    }
                }
            }
            
            await messages.removeSubscriptionMessages(with: messagesToDelete.compactMap{$0})
            await messages.updateSubscriptionMessages(with: messageToUpdate.compactMap{$0})
            
            if dontSend == false {
                let requestMode: RequestMode = includeReply ? .sendDataBackWithSubscription : .dontSendBack
                let message = SubscribeMessage(
                    id: finalSubscriptionId,
                    payload: payload,
                    checksum: cache?.checksum ?? 0,
                    requestMode: requestMode,
                    functionName: name
                )
                
                addToMessages(message)
            }
        }
        
        return (finalSubscriptionId, subscriberId)
    }
    
    
    ///
    /// - Parameters:
    ///   - subscriptionId: subscriptionId description
    ///   - subscriberId: subscriberId description
    func shouldSendDataFromCache(for subscriptionId: SubscriptionId, and subscriberId: SubscriberId) async {
        guard
            let cache = await cache.fetch(with: subscriptionId),
            let subscription = await subscriptionManager.subscription(with: subscriptionId)
            else { return }
        
        await subscription.subscribers[subscriberId]?.onData?(cache.value, cache.checksum)
        await subscriptionManager.updateSubscription(with: subscriptionId, subscription: subscription)
    }
    
    
    ///
    /// - Parameter data: data description
    func incomingSubscription(_ data: SubscriptionData) async {
        guard
            var subscription = await subscriptionManager.subscription(with: data.id)
        else { return }
        
        let cache = await cache.fetch(with: data.id)
        let previousChecksum = cache?.checksum
        dataInfo("Checksum in. previous: \(String(describing: previousChecksum)). New \(String(describing: data.checksum)). Error: \(String(describing: data.error))")
        
        if let error = data.error {
            let err = BasedError.from(error)
            
            if error.auth == true {
                subscription.error = err
            }
            
            for (subscriberId, callback) in subscription.subscribers {
                if data.error?.auth != true {
                    await removeSubscriber(subscriptionId: data.id, subscriberId: subscriberId)
                } else {
                    await callback.onError?(err)
                }
            }
            
            await subscriptionManager.updateSubscription(with: data.id, subscription: subscription)
            
            return
        }
        
        if previousChecksum == data.checksum {
            
            subscription.error = nil
            
            subscription.subscribers.forEach { subscriberId, callback in
                if callback.onData == nil {
                    Task {
                        await removeSubscriber(subscriptionId: data.id, subscriberId: subscriberId)
                    }
                }
            }
            
            await subscriptionManager.updateSubscription(with: data.id, subscription: subscription)
        } else {
            if subscription.error != nil {
                subscription.error = nil
                await subscriptionManager.updateSubscription(with: data.id, subscription: subscription)
            }
            
            await self.cache.store(data.id, data: (data.data, data.checksum ?? 0))
            
            for (subscriberId, callback) in subscription.subscribers {
                if callback.onData == nil {
                    await removeSubscriber(subscriptionId: data.id, subscriberId: subscriberId)
                } else {
                    await callback.onData?(data.data, data.checksum ?? 0)
                }
            }
            
        }
    }
    

    
    ///
    /// - Parameter data: data description
    func incomingSubscriptionDiff(_ data: SubscriptionDiffData) async {
        guard
            let subscription = await subscriptionManager.subscription(with: data.id)
        else { return }
        
        var cache = await cache.fetch(with: data.id)
        
        if cache == nil || cache?.checksum != data.checksums.previous {
            if cache != nil {
                if cache?.checksum == data.checksums.current {
                    subscription.subscribers.forEach { subscriberId, callback in

                        if callback.onData == nil {
                            Task { await removeSubscriber(subscriptionId: data.id, subscriberId: subscriberId) }
                        }
                    }
                } else {
                    addToMessages(SendSubscriptionDataMessage(id: data.id, checksum: nil))
                }
            } else {
                addToMessages(SendSubscriptionDataMessage(id: data.id, checksum: nil))
            }
        } else {
            
            var isCorrupt = false
            if
                let value = cache?.value,
                let json = try? decoder.decode(Json.self, from: value),
                let patched = Current.patcher.applyPatch(json, data.patchObject),
                let encodedPatch = try? encoder.encode(patched) {
                
                cache?.value = encodedPatch
                if let updatedCache = cache {
                    await self.cache.store(data.id, data: updatedCache)
                }
                
                
            } else {
                isCorrupt = true
            }
            
            if isCorrupt == false {
                cache?.checksum = data.checksums.current
                if let updatedCache = cache {
                    await self.cache.store(data.id, data: updatedCache)
                }
                for (subscriberId, callback) in subscription.subscribers {
                    if callback.onData == nil {
                        await removeSubscriber(subscriptionId: data.id, subscriberId: subscriberId)
                    }
                    if let checksum = cache?.checksum, let value = cache?.value {
                        await callback.onData?(value, checksum)
                    }
                }
            } else {
                await self.cache.remove(with: data.id)
                addToMessages(SendSubscriptionDataMessage(id: data.id, checksum: nil))
            }
        }
    }
    

    
    /// Description
    /// - Parameters:
    ///   - subscriptionId: subscriptionId description
    ///   - subscriberId: subscriberId description
    func removeSubscriber(subscriptionId: SubscriptionId, subscriberId: SubscriberId? = nil) async {
        
        guard
            var subscription = await subscriptionManager.subscription(with: subscriptionId)
        else {
            return
        }

        
        var remove = false
        
        if let subscriberId = subscriberId {
            if subscription.subscribers[subscriberId] != nil {
                subscription.subscribers.removeValue(forKey: subscriberId)
                
                await subscriptionManager.updateSubscription(with: subscriptionId, subscription: subscription)
                
                if subscription.subscribers.count <= 0 {
                    remove = true
                }
            }
        } else {
            remove = true
        }
        
        if remove {
            
            await subscriptionManager.removeSubscription(with: subscriptionId)
            
            var dontSend = false
            
            let subscriptionMessages = await messages.allSubscriptionMessages()
            
            for (index, subscriptionMessage) in subscriptionMessages.enumerated() {
                switch subscriptionMessage {
                case is UnsubscribeMessage where subscriptionMessage.id == subscriptionId:
                    dontSend = true
                case is SubscribeMessage where subscriptionMessage.id == subscriptionId,
                    is SendSubscriptionDataMessage where subscriptionMessage.id == subscriptionId:
                    await messages.removeSubscriptionMessage(at: index)
                default:
                    break
                }
            }
            
            if !dontSend {
                addToMessages(UnsubscribeMessage(id: subscriptionId))
            }
        }
        
    }
}
