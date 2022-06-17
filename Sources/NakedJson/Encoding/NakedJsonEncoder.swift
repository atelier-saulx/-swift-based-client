import Foundation

public struct NakedJsonEncoder {
    public struct Options {
        var converters: [ObjectIdentifier: EncodingConverter] = [:]
        var userInfo: [CodingUserInfoKey: Any] = [:]
        
        public init(converters: [EncodingConverter], userInfo: [CodingUserInfoKey: Any] = [:]) {
            self.converters = converters.reduce(into: [:]) { partialResult, converter in
                partialResult[ObjectIdentifier(converter.sourceType)] = converter
            }
            self.userInfo = userInfo
        }
        
        public static let `default`: Self = .init(converters: [
            .absoluteUrl,
        ])
    }
    
    let options: Options
    
    public init(options: Options = .default) {
        self.options = options
    }
    
    public func encode<Value: Encodable>(_ value: Value) throws -> Json {
        let encoder = NakedJsonEncoderImpl(options: options, codingPath: [])
        guard let value = try encoder.wrapEncodable(value, for: nil) else {
            throw EncodingError.invalidValue(value, EncodingError.Context(codingPath: [], debugDescription: "Top-level \(Value.self) did not encode any values."))
        }
        return value
    }
}

protocol ConvertingEncoder {
    var codingPath: [CodingKey] { get }
    var encoder: NakedJsonEncoderImpl { get }
}

extension ConvertingEncoder {
    func wrapEncodable<Value: Encodable>(_ value: Value, for additionalKey: CodingKey?) throws -> Json? {
        if let converter = encoder.options.converters[ObjectIdentifier(Value.self)] {
            return try converter.converter(codingPath, value)
        } else {
            let encoder = self.getEncoder(for: additionalKey)
            try value.encode(to: encoder)
            return encoder.value
        }
    }
    
    func getEncoder(for additionalKey: CodingKey?) -> NakedJsonEncoderImpl {
        if let additionalKey = additionalKey {
            let newCodingPath = self.codingPath + [additionalKey]
            return NakedJsonEncoderImpl(options: encoder.options, codingPath: newCodingPath)
        }
        
        return encoder
    }
}

enum JsonAccumulator {
    case json(Json)
    case encoder(NakedJsonEncoderImpl)
    case array(ArrayAccumulator)
    case object(ObjectAccumulator)
    
    var value: Json {
        switch self {
        case .json(let json):
            return json
        case .encoder(let nakedJsonEncoderImpl):
            return nakedJsonEncoderImpl.value ?? [:]
        case .array(let arrayAccumulator):
            return .array(arrayAccumulator.values)
        case .object(let objectAccumulator):
            return .object(objectAccumulator.values)
        }
    }
}

final class ArrayAccumulator {
    var content: [JsonAccumulator] = []
    
    var values: [Json] {
        content.map(\.value)
    }
    
    func append(_ value: Json) {
        content.append(.json(value))
    }
    
    func append(_ encoder: NakedJsonEncoderImpl) {
        content.append(.encoder(encoder))
    }
    
    func appendArray() -> ArrayAccumulator {
        let result = ArrayAccumulator()
        content.append(.array(result))
        return result
    }
    
    func appendObject() -> ObjectAccumulator {
        let result = ObjectAccumulator()
        content.append(.object(result))
        return result
    }
}

final class ObjectAccumulator {
    var content: [String: JsonAccumulator] = [:]
    
    var values: [String: Json] {
        content.mapValues(\.value)
    }
    
    func append(_ value: Json, for key: CodingKey) {
        content[key.stringValue] = .json(value)
    }
    
    func append(_ encoder: NakedJsonEncoderImpl, for key: CodingKey) {
        content[key.stringValue] = .encoder(encoder)
    }
    
    func appendArray(for key: CodingKey) -> ArrayAccumulator {
        let result = ArrayAccumulator()
        content[key.stringValue] = .array(result)
        return result
    }
    
    func appendObject(for key: CodingKey) -> ObjectAccumulator {
        let result = ObjectAccumulator()
        content[key.stringValue] = .object(result)
        return result
    }
}

final class NakedJsonEncoderImpl: Encoder {
    let options: NakedJsonEncoder.Options
    let codingPath: [CodingKey]
    var userInfo: [CodingUserInfoKey: Any] {
        options.userInfo
    }

    var singleValue: Json?
    var array: ArrayAccumulator?
    var object: ObjectAccumulator?

    var value: Json? {
        if let object = self.object {
            return .object(object.values)
        }
        if let array = self.array {
            return .array(array.values)
        }
        return self.singleValue
    }
    
    init(options: NakedJsonEncoder.Options, codingPath: [CodingKey]) {
        self.options = options
        self.codingPath = codingPath
    }
    
    func singleValueContainer() -> SingleValueEncodingContainer {
        guard self.object == nil, self.array == nil else {
            preconditionFailure()
        }

        return NakedJsonSingleValueEncodingContainer(codingPath: codingPath, encoder: self)
    }
    
    func unkeyedContainer() -> UnkeyedEncodingContainer {
        if let array = array {
            return NakedJsonUnkeyedEncodingContainer(encoder: self, array: array, codingPath: codingPath)
        }
        
        guard object == nil, singleValue == nil else {
            preconditionFailure()
        }
        
        array = ArrayAccumulator()
        return NakedJsonUnkeyedEncodingContainer(encoder: self, codingPath: codingPath)
    }
    
    func container<Key>(keyedBy type: Key.Type) -> KeyedEncodingContainer<Key> where Key : CodingKey {
        if let object = object {
            let container = NakedJsonKeyedEncodingContainer<Key>(encoder: self, object: object, codingPath: codingPath)
            return KeyedEncodingContainer(container)
        }
        
        guard array == nil, singleValue == nil else {
            preconditionFailure()
        }
        
        object = ObjectAccumulator()
        let container = NakedJsonKeyedEncodingContainer<Key>(encoder: self, codingPath: codingPath)
        return KeyedEncodingContainer(container)
    }
}

extension NakedJsonEncoderImpl: ConvertingEncoder {
    var encoder: NakedJsonEncoderImpl {
        self
    }
}
