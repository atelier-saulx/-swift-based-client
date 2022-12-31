//
//  File.swift
//  
//
//  Created by Alexander van der Werff on 25/12/2022.
//

import Foundation

extension String {
    func makeCString() -> UnsafeMutablePointer<CChar> {
        let count = utf8.count + 1
        let result = UnsafeMutablePointer<CChar>.allocate(capacity: count)
        withCString { baseAddress in
            result.initialize(from: baseAddress, count: count)
        }
        return result
    }
}
