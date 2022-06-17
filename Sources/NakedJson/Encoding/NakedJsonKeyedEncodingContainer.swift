import Foundation

struct NakedJsonKeyedEncodingContainer<Key: CodingKey>: KeyedEncodingContainerProtocol, ConvertingEncoder {
    var encoder: NakedJsonEncoderImpl
    var object: ObjectAccumulator
    var codingPath: [CodingKey]
    
    init(encoder: NakedJsonEncoderImpl, codingPath: [CodingKey]) {
        self.encoder = encoder
        self.object = encoder.object!
        self.codingPath = codingPath
    }
    
    init(encoder: NakedJsonEncoderImpl, object: ObjectAccumulator, codingPath: [CodingKey]) {
        self.encoder = encoder
        self.object = object
        self.codingPath = codingPath
    }
    
    mutating func encodeNil(forKey key: Key) throws {
        object.append(.null, for: key)
    }
    
    mutating func encode(_ value: Bool, forKey key: Key) throws {
        object.append(.bool(value), for: key)
    }
    
    mutating func encode(_ value: String, forKey key: Key) throws {
        object.append(.string(value), for: key)
    }
    
    mutating func encode(_ value: Double, forKey key: Key) throws {
        object.append(.double(value), for: key)
    }
    
    mutating func encode(_ value: Float, forKey key: Key) throws {
        object.append(.double(value), for: key)
    }
    
    mutating func encode(_ value: Int, forKey key: Key) throws {
        object.append(.int(value), for: key)
    }
    
    mutating func encode(_ value: Int8, forKey key: Key) throws {
        object.append(.int(value), for: key)
    }
    
    mutating func encode(_ value: Int16, forKey key: Key) throws {
        object.append(.int(value), for: key)
    }
    
    mutating func encode(_ value: Int32, forKey key: Key) throws {
        object.append(.int(value), for: key)
    }
    
    mutating func encode(_ value: Int64, forKey key: Key) throws {
        object.append(.int(value), for: key)
    }
    
    mutating func encode(_ value: UInt, forKey key: Key) throws {
        object.append(.int(value), for: key)
    }
    
    mutating func encode(_ value: UInt8, forKey key: Key) throws {
        object.append(.int(value), for: key)
    }
    
    mutating func encode(_ value: UInt16, forKey key: Key) throws {
        object.append(.int(value), for: key)
    }
    
    mutating func encode(_ value: UInt32, forKey key: Key) throws {
        object.append(.int(value), for: key)
    }
    
    mutating func encode(_ value: UInt64, forKey key: Key) throws {
        object.append(.int(value), for: key)
    }
    
    mutating func encode<Value: Encodable>(_ value: Value, forKey key: Key) throws {
        let encoded = try wrapEncodable(value, for: key)
        self.object.append(encoded ?? [:], for: key)
    }
    
    mutating func nestedContainer<NestedKey: CodingKey>(keyedBy keyType: NestedKey.Type, forKey key: Key) -> KeyedEncodingContainer<NestedKey> {
        let convertedKey = key
        let newPath = codingPath + [convertedKey]
        let object = object.appendObject(for: convertedKey)
        let nestedContainer = NakedJsonKeyedEncodingContainer<NestedKey>(encoder: encoder, object: object, codingPath: newPath)
        return KeyedEncodingContainer(nestedContainer)
    }
    
    mutating func nestedUnkeyedContainer(forKey key: Key) -> UnkeyedEncodingContainer {
        let array = object.appendArray(for: key)
        let nestedContainer = NakedJsonUnkeyedEncodingContainer(encoder: encoder, array: array, codingPath: codingPath)
        return nestedContainer
    }
    
    mutating func superEncoder() -> Encoder {
        let newEncoder = self.getEncoder(for: JsonKey.super)
        object.append(newEncoder, for: JsonKey.super)
        return newEncoder
    }
    
    mutating func superEncoder(forKey key: Key) -> Encoder {
        let newEncoder = self.getEncoder(for: key)
        object.append(newEncoder, for: key)
        return newEncoder
    }
    
    func getEncoder(for additionalKey: CodingKey?) -> NakedJsonEncoderImpl {
        if let additionalKey = additionalKey {
            let newCodingPath = self.codingPath + [additionalKey]
            return NakedJsonEncoderImpl(options: encoder.options, codingPath: newCodingPath)
        }
        
        return encoder
    }
}
