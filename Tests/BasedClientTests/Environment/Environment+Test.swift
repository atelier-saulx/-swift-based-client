//
//  File.swift
//  
//
//  Created by Alexander van der Werff on 28/12/2022.
//

import Foundation
@testable import BasedClient

extension Environment {
    static let mock: Environment = .init(
        basedClient: .mock(nil, nil)
    )
}
