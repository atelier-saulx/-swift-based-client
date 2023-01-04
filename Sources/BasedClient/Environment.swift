//
//  Environment.swift
//  
//
//  Created by Alexander van der Werff on 25/12/2021.
//

import Foundation

var Current: Environment = .default

struct Environment {
    var basedClient: BasedClient = .default
}

extension Environment {
    static let `default`: Environment = .init(
        basedClient: .default
    )
}
