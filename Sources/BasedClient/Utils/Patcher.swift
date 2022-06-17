//
//  Patcher.swift
//  
//
//  Created by Alexander van der Werff on 17/12/2021.
//

import Foundation
import NakedJson

struct Patcher {
    let applyPatch: (_ input: Json?, _ patch: Json) -> Json?
}

extension Patcher {
    static let `default` = Self { input, patch in
        guard var value = input else { return nil }
        
        if let array = patch.arrayValue, let type = array[0].intValue {
            // 0 - insert
            // 1 - remove
            // 2 - array
            switch type {
            case 0: return array[1]
            case 1: return nil
            case 2:
                return applyArrayPatch(value: value, arrayPatch: array[1])
            default: break;
            }
        } else if let patchObject = patch.objectValue {
            if patchObject["___$toObject"] != nil, let inputValueArray = value.arrayValue {
                var v = [String: Json]()

                for (index, elm) in inputValueArray.enumerated() {
                    v["\(index)"] = elm
                }
                
                value = Json.object(v)
            }
            
            for (key, val) in patchObject {
                if key != "___$toObject",  let v = nestedApplyPatch(inputValue: value, key: key, patch: val) {
                    value = v
                }
            }
        }
        
        return value
    }

    
    /**
     
     */
    private static func applyArrayPatch(value: Json, arrayPatch: Json) -> Json? {
        guard
            let arrayPatch = arrayPatch.arrayValue,
            let value = value.arrayValue
        else { return nil }
        var newArray = [Json]()
        
        var aI = -1
        var patches = [(aI: Int, j: Int, patch: Json)]()
        var used = Set<Int>()
        
        for i in 1..<arrayPatch.count {
            // 0 - insert, value
            // 1 - from , index, amount (can be a copy a well)
            // 2 - amount, index
            if let operation = arrayPatch[i].arrayValue, let type = operation[0].intValue {
                switch type {
                case 0:
                    for j in 1..<operation.count {
                        aI += 1
                        if newArray.count == aI + 1 {
                            newArray[aI] = operation[j]
                        } else {
                            newArray.append(operation[j])
                        }
                    }
                case 1:
                    guard
                        let piv = operation[2].intValue,
                        let operationOne = operation[1].intValue
                    else { return nil }
                    
                    let range = operationOne + piv
                    for j in piv..<range {
                        if used.contains(j) {
                            aI += 1
                            if newArray.count == aI + 1 {
                                newArray[aI] = value[j]
                            } else {
                                newArray.append(value[j])
                            }
                            
                        } else {
                            used.insert(j)
                            aI += 1
                            if newArray.count == aI + 1 {
                                newArray[aI] = value[j]
                            } else {
                                newArray.append(value[j])
                            }
                        }
                    }
                case 2:
                    guard
                        let piv = operation[1].intValue
                    else { return nil }
                    
                    let range = operation.count - 2 + piv
                    for j in piv..<range {
                        aI += 1
                        patches.append((aI: aI, j: j, patch: operation[j - piv + 2]))
                    }
                default: break
                }
            }
        }
        
        patches.forEach { item in
            if let newObject = Current.patcher.applyPatch(value[item.j], item.patch) {
                newArray.insert(newObject, at: item.aI)
            }
        }
        
        return Json.array(newArray)

    }
    
    /**
     
     */
    private static func nestedApplyPatch(inputValue: Json, key: String, patch: Json) -> Json? {
        var value = inputValue.objectValue
        if let patch = patch.arrayValue, let type = patch[0].intValue {
            // 0 - insert
            // 1 - remove
            // 2 - array
            switch type {
            case 0:
                value?[key] = patch[1]
            case 1:
                value?.removeValue(forKey: key)
            case 2:
                if let objectValue = value?[key], let r = applyArrayPatch(value: objectValue, arrayPatch: patch[1]) {
                    value?[key] = r
                } else {
                    return nil
                }
            default: break
            }
        }
        else if let patchObject = patch.objectValue {
            if patchObject["___$toObject"] != nil, let array = value?[key]?.arrayValue {
                var v = [String: Json]()
                
                for (index, elm) in array.enumerated() {
                    v["\(index)"] = elm
                }
                value?["\(key)"] = Json.object(v)
            }
            if value?[key] == nil {
                return nil
            }
            else {
                for (nkey, val) in patchObject {
                    if nkey != "___$toObject", let vJson = value?[key] {
                        if let v = nestedApplyPatch(inputValue: vJson, key: nkey, patch: val) {
                            value?[key] = v
                        } else {
                            return nil
                        }
                    }
                }
            }
        }
        if let object = value {
            return Json.object(object)
        } else {
            return nil
        }
    }
}



