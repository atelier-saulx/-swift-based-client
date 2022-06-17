//
//  File.swift
//  
//
//  Created by Alexander van der Werff on 27/09/2021.
//

import Foundation

struct TokenMessage: Message {
    let requestType: RequestType = .token
    let id: Int = 0
    var token: String?
    var checksum: Int? = nil
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.unkeyedContainer()
        
        try container.encode(requestType)
        try container.encode(token)
        try container.encode(checksum)
    }
}
