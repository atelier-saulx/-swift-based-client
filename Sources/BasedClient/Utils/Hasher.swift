//
//  Hash.swift
//  
//
//  Created by Alexander van der Werff on 10/12/2021.
//

import Foundation
import NakedJson

infix operator >>>> : BitwiseShiftPrecedence

func >>>> (lhs: Int32, rhs: Int32) -> Int32 {
    if lhs >= 0 {
        return lhs >> rhs
    } else {
        return (Int32.max + lhs + 1) >> rhs | (1 << (63-rhs))
    }
}

struct Hasher {
    let hashObjectIgnoreKeyOrder: (_ input: Json) -> Int
}

extension Hasher {
    static let `default` = Self { input in
        let x = hashObjectIgnoreKeyOrderNest(input)
        let x1 = Int(x.0 >>>> 0)
        let x2 = Int(x.1)
        return x1 * 4096 + x2
    }
    
    static private func hashObjectIgnoreKeyOrderNest(_ input: Json, _ startHash: Int32 = 5381, _ startHash2: Int32 = 52711) -> (Int32, Int32) {
        var hash = startHash
        var hash2 = startHash2
        
        if let array = input.arrayValue {
            let fl = "__len:\(array.count)}1"
            hash = stringHash(fl, hash)
            hash2 = stringHash(fl, hash2)
            
            for (index, element) in array.enumerated() {
                if let _ = element.objectValue {
                    let x = hashObjectIgnoreKeyOrderNest(element, hash, hash2)
                    let f = "\(index)o:"
                    hash = stringHash(f, x.0)
                    hash2 = stringHash(f, x.1)
                } else {
                    var f = ""
                    switch element {
                    case .string(let value):
                        f = "\(index):\(value)"
                    case .int(let value):
                        f = "\(index):\(value)"
                    case .double(let value):
                        f = "\(index):\(value)"
                    case .null:
                        f = "\(index):null"
                    case .bool(let value):
                        f = "\(index)b:\(value ? "true" : "false")"
                    default:
                        break
                    }
                    hash = stringHash(f, hash)
                    hash2 = stringHash(f, hash2)
                }
            }
        } else if let object = input.objectValue {
            let keys = object.keys.sorted()
            let fl = "__len:\(keys.count)1"
            hash = stringHash(fl, hash)
            hash2 = stringHash(fl, hash2)
            
            for (_, key) in keys.enumerated() {
                if let field = object[key], let _ = field.objectValue {
                    let x = hashObjectIgnoreKeyOrderNest(field, hash, hash2)
                    let f = "\(key)o:"
                    hash = stringHash(f, x.0)
                    hash2 = stringHash(f, x.1)
                } else if let field = object[key], let array = field.arrayValue {
                    let x = hashObjectIgnoreKeyOrder(array, hash, hash2)
                    hash = x.0
                    hash2 = x.1
                    let f = "\(key)o:"
                    hash = stringHash(f, hash)
                    hash2 = stringHash(f, hash2)
                } else if let field = object[key] {
                    
                    var f = ""
                    
                    switch field {
                    case .string(let value):
                        f = "\(key):\(value)"
                    case .int(let value):
                        f = "\(key)n:\(value)"
                    case .double(let value):
                        f = "\(key)n:\(value)"
                    case .null:
                        f = "\(key)v:null"
                    case .bool(let value):
                        f = "\(key)b:\(value ? "true" : "false")"
                    default:
                        break
                    }
 
                    hash = stringHash(f, hash)
                    hash2 = stringHash(f, hash2)
                }
            }
        }
        return (hash, hash2)
    }
    
    
    static private func hashObjectIgnoreKeyOrder(_ array: [Json], _ startHash: Int32, _ secondHash: Int32) -> (Int32, Int32) {
        var hash = startHash
        var hash2 = secondHash

        let fl = "__len:\(array.count)1"
        hash = stringHash(fl, hash)
        hash2 = stringHash(fl, hash2)

        for (index, element) in array.enumerated() {
            if let _ = element.objectValue {
                let x = hashObjectIgnoreKeyOrderNest(element, hash, hash2)
                let f = "\(index)o:"
                hash = stringHash(f, x.0)
                hash2 = stringHash(f, x.1)
            } else {
                
                var f = ""
                switch element {
                case .string(let value):
                    f = "\(index):\(value)"
                case .int(let value):
                    f = "\(index):\(value)"
                case .double(let value):
                    f = "\(index):\(value)"
                case .null:
                    f = "\(index):null"
                case .bool(let value):
                    f = "\(index)b:\(value ? "true" : "false")"
                default:
                    break
                }
                hash = stringHash(f, hash)
                hash2 = stringHash(f, hash2)
                
            }
        }
        return (hash, hash2)
    }
    
//    static private func stringHash(_ input: String, _ inputHash: Int = 5381) -> Int {
//        var hash = UInt(inputHash)
//        let codes = Array(input).reversed().compactMap { $0.asciiValue }.map { UInt($0) }
//        codes.forEach { c in
//            hash = (hash * 33) ^ c
//        }
//        return Int(hash)
//    }
    
    static private func stringHash(_ key: String, _ inputHash: Int32 = 5381) -> Int32 {
        let scalarStrings = key.unicodeScalars.map { $0.value }
        let value = scalarStrings.reversed().reduce(inputHash) {
            ($0 << 5) &+ $0 &+ Int32($1)
        }
        return value
    }
    
}
