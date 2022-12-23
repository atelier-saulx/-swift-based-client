//
//  Environment.swift
//  
//
//  Created by Alexander van der Werff on 25/12/2021.
//

import Foundation

var Current = Environment()

struct Environment {
    var patcher: Patcher = .default
    var hasher: Hasher = .default
    var basedClientWrapper: BasedClientWrapper = .default
}
