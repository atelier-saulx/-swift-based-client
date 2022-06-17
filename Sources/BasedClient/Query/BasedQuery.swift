//
//  BasedQuery.swift
//  
//
//  Created by Alexander van der Werff on 19/09/2021.
//

import Foundation
import NakedJson

public typealias QueryItem = BasedQuery.QueryItem
public typealias Query = BasedQuery

public enum BasedQuery {
    case query([QueryItem])
    public enum QueryItem {
        indirect case item(_ name: String, values: [String]? = nil, value: Bool? = nil, items: [QueryItem]? = nil)
        
        public static func field(_ name: String, _ items: QueryItem...) -> Self {
            .item(name, items: items)
        }
        
        public static func field(_ name: String, _ value: Bool) -> Self {
            .item(name, value: value)
        }
        
        public static func field(_ name: String, _ values: String...) -> Self {
            .item(name, values: values)
        }
    }
}

public extension BasedQuery {
    static func query(_ values: QueryItem...) -> BasedQuery {
        .query(values)
    }
    
    func jsonStringify() -> String {
        var jsonString = "{"
        switch self {
        case .query(let items):
            items.map(Self.jsonStringify).joined(separator: ", ").forEach { jsonString.append($0) }
        }
        jsonString += "}"
        return jsonString
    }
    
    private static func jsonStringify(_ item: QueryItem) -> String {
        var jsonString = ""
          switch item {
          case let .item(name, values, value, items):
            jsonString.append("\"\(name)\": ")
            if let values = values {
                if values.count > 1 {
                    jsonString.append(values.jsonStringify())
                } else {
                    jsonString.append("\"\(values[0])\"")
                }
            } else if let value = value {
                jsonString.append("\(value)")
            }
            if let items = items {
                jsonString.append("{")
                items.map(jsonStringify).joined(separator: ", ").forEach { jsonString.append($0) }
                jsonString.append("}")
            }
          }
        return jsonString
    }
    
    func dictionary() -> [String: Json] {
        switch self {
        case .query(let items):
            return .init(items.flatMap(Self.dictionary), uniquingKeysWith: { $1 })
        }
    }
    
    private static func dictionary(_ item: QueryItem) -> [String: Json] {
        var dictionary = [String: Json]()
        switch item {
          case let .item(name, values, value, items):
            if let values = values {
                if values.count > 1 {
                    dictionary[name] = .array(values.map(Json.string))
                } else {
                    dictionary[name] = .string(values[0])
                }
            } else if let value = value {
                dictionary[name] = .bool(value)
            }
            if let items = items {
                dictionary[name] = Json.object(.init(items.flatMap(Self.dictionary), uniquingKeysWith: { $1 }))
            }
          }
        return dictionary
    }
}
