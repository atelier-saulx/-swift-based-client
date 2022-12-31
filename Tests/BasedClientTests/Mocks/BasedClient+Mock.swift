//
//  File.swift
//  
//
//  Created by Alexander van der Werff on 28/12/2022.
//

import Foundation
@testable import BasedClient

extension BasedClient {
    static let mock: (MockBasedCClient?, GetCallbackStore?) -> BasedClient = { mock, getCallbacks in
        guard let mock = mock, let getCallbacks = getCallbacks else {
            return .init()
        }
        return .init(cClient: mock, getCallbacks: getCallbacks )
    }
}
