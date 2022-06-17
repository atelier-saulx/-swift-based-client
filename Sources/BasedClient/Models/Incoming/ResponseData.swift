//
//  ResponseData.swift
//  
//
//  Created by Alexander van der Werff on 27/09/2021.
//

import Foundation
import NakedJson

protocol ResponseData {
    var requestType: RequestType { get }
}

struct SubscriptionDiffData: ResponseData {
    var requestType: RequestType { .subscriptionDiff }
    let id: Int
    let patchObject: Json
    let checksums: (previous: Int, current: Int)
}

struct SubscriptionData: ResponseData, Decodable {
    var requestType: RequestType { .sendSubscriptionData }
    let id: Int
    let data: Data
    var checksum: Int?
    let error: ErrorObject?
}

//[RequestTypes.Token, number[], boolean?]
struct AuthorizedData: ResponseData {
    var requestType: RequestType { .token }
    let subscriptionIds: [Int]
}
