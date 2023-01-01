//
//  File.swift
//  
//
//  Created by Alexander van der Werff on 28/12/2022.
//

import Foundation
@testable import BasedClient

extension BasedClient {
    static let mock: (MockBasedCClient?, GetCallbackStore?, FunctionCallbackStore?, ObserveCallbackStore?) -> BasedClient = { mock, getCallbacks, funcCallbacks, observeCallbacks in
        guard let mock = mock, let getCallbacks = getCallbacks, let funcCallbacks = funcCallbacks, let observeCallbacks = observeCallbacks else {
            return .init()
        }
        return .init(
            cClient: mock,
            observeCallbacks: observeCallbacks,
            getCallbacks: getCallbacks,
            functionCallbacks: funcCallbacks
        )
    }
}
