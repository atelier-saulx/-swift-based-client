//
//  FunctionCallMessage.swift
//  
//
//  Created by Alexander van der Werff on 27/09/2021.
//

import Foundation
import NakedJson

struct FunctionCallMessage: SubscriptionMessage {
    var requestType: RequestType { .call }
    let id: Int
    let name: String
    var payload: Json = nil
    var checksum: Int?
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.unkeyedContainer()
        
        try container.encode(requestType)
        try container.encode(name)
        try container.encode(id)
        try container.encode(payload)
//        ?????
//        try container.encode(checksum)
    }
}
