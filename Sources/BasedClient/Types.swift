//
//  Types.swift
//  
//
//  Created by Alexander van der Werff on 31/08/2021.
//

import Foundation

public typealias DataCallback = (_ data: Data, _ checksum: Int) async -> Void
public typealias ErrorCallback = (_ error: BasedError) async -> Void
public typealias InitialCallback = (
    _ error: BasedError,
    _ subscriptionId: SubscriptionId?,
    _ subscriberId: SubscriberId?,
    _ data: Any?
) -> ()


typealias DigestOptions = String

enum RequestType: Int, Codable, CustomStringConvertible, CaseIterable {
    case subscription = 1,
    subscriptionDiff = 2,
    sendSubscriptionData = 3,
    unsubscribe = 4,
    set = 5,
    get = 6,
    configuration = 7,
    getConfiguration = 8,
    call = 9,
    getSubscription = 10,
    delete = 11,
    copy = 12,
    digest = 13,
    token = 14,
    track = 15
    
    var description: String {
        return "\(self.rawValue)"
    }
}
