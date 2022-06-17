//
//  SubscriptionMessage.swift
//  
//
//  Created by Alexander van der Werff on 13/09/2021.
//

import Foundation
import NakedJson

// Outgoing data

// 0 = don't send data back if the same checksum but make subscription
// 1 = send data back, do not make a subscription
// 2 = allways send data back, make subscription
enum RequestMode: Int, Codable {
    case dontSendBack = 0, sendDataBack, sendDataBackWithSubscription
}

protocol HighLevelEncoder {
    associatedtype Target
    
    func encode<Source: Encodable>(_ value: Source) throws -> Target
}

extension NakedJsonEncoder: HighLevelEncoder {}

protocol Message: Encodable {
    var requestType: RequestType { get }
    var id: Int { get }
    var checksum: Int? { get set }
}

extension Message {
    func encode<Encoder: HighLevelEncoder>(with encoder: Encoder) throws -> Encoder.Target {
        return try encoder.encode(self)
    }
}

protocol SubscriptionMessage: Message {}

struct RequestMessage: Message {
    var requestType: RequestType
    var id: Int
    var payload: Json = nil
    var checksum: Int? = nil
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.unkeyedContainer()
        
        try container.encode(requestType)
        try container.encode(id)
        try container.encode(payload)
        try container.encode(checksum)
    }
}

struct SubscribeMessage: SubscriptionMessage {
    var requestType: RequestType { .subscription }
    var id: Int
    var payload: Json = nil
    var checksum: Int?
    var requestMode: RequestMode?
    var functionName: String?
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.unkeyedContainer()
        
        try container.encode(requestType)
        try container.encode(id)
        try container.encode(payload)
        try container.encode(checksum)
        try container.encode(requestMode)
        try container.encode(functionName)
    }
}

struct SendSubscriptionDataMessage: SubscriptionMessage {
    var requestType: RequestType { .sendSubscriptionData }
    var id: Int
    var checksum: Int?
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.unkeyedContainer()
        
        try container.encode(requestType)
        try container.encode(id)
        try container.encode(checksum)
    }
}

struct SendSubscriptionGetDataMessage: SubscriptionMessage {
    var requestType: RequestType { .getSubscription }
    var id: Int
    var query: Json = nil
    var checksum: Int?
    var customObservableFuncName: String?
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.unkeyedContainer()
        
        try container.encode(requestType)
        try container.encode(id)
        try container.encode(query)
        try container.encode(checksum)
        try container.encode(customObservableFuncName)
    }
}

struct UnsubscribeMessage: SubscriptionMessage {
    var requestType: RequestType { .unsubscribe }
    var id: Int
    var checksum: Int?
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.unkeyedContainer()
        
        try container.encode(requestType)
        try container.encode(id)
        try container.encode(checksum)
    }
}
