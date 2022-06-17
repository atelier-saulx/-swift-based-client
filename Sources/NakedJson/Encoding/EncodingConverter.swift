import Foundation

public struct EncodingConverter {
    let sourceType: Any.Type
    let converter: ([CodingKey], Encodable) throws -> Json
    
    public init<Value: Encodable>(type: Value.Type = Value.self, converter: @escaping (Value) throws -> Json) {
        self.sourceType = Value.self
        self.converter = { codingPath, value in
            guard
                let value = value as? Value
            else {
                throw EncodingError.invalidValue(value, .init(
                    codingPath: codingPath,
                    debugDescription: "\(value) is not of type \(Value.self)"
                ))
            }
            
            return try converter(value)
        }
    }
}

extension EncodingConverter {
    static let nullDate: Self = .init(type: Date.self) { date in
        return .null
    }
    
    static let absoluteUrl: Self = .init(type: URL.self) { url in
        return .string(url.absoluteString)
    }
}
