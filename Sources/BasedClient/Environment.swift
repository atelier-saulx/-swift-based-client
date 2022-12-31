//
//  Environment.swift
//  
//
//  Created by Alexander van der Werff on 25/12/2021.
//

import Foundation

var Current: Environment = .default

struct Environment {
    var patcher: Patcher = .default
    var hasher: Hasher = .default
    var basedClient: BasedClient = .default
}

extension Environment {
    static let `default`: Environment = .init(
        patcher: .default,
        hasher: .default,
        basedClient: .default
    )
}
