import Foundation

struct NakedJsonUnkeyedEncodingContainer: UnkeyedEncodingContainer, ConvertingEncoder {
    var encoder: NakedJsonEncoderImpl
    var array: ArrayAccumulator
    var codingPath: [CodingKey]
    
    var count: Int {
        encoder.array?.content.count ?? 0
    }
    
    init(encoder: NakedJsonEncoderImpl, codingPath: [CodingKey]) {
        self.encoder = encoder
        self.array = encoder.array!
        self.codingPath = codingPath
    }
    
    init(encoder: NakedJsonEncoderImpl, array: ArrayAccumulator, codingPath: [CodingKey]) {
        self.encoder = encoder
        self.array = array
        self.codingPath = codingPath
    }
    
    mutating func encodeNil() throws {
        array.append(.null)
    }
    
    mutating func encode(_ value: Bool) throws {
        array.append(.bool(value))
    }

    mutating func encode(_ value: String) throws {
        array.append(.string(value))
    }

    mutating func encode(_ value: Double) throws {
        array.append(.double(value))
    }

    mutating func encode(_ value: Float) throws {
        array.append(.double(value))
    }

    mutating func encode(_ value: Int) throws {
        array.append(.int(value))
    }

    mutating func encode(_ value: Int8) throws {
        array.append(.int(value))
    }

    mutating func encode(_ value: Int16) throws {
        array.append(.int(value))
    }

    mutating func encode(_ value: Int32) throws {
        array.append(.int(value))
    }

    mutating func encode(_ value: Int64) throws {
        array.append(.int(value))
    }

    mutating func encode(_ value: UInt) throws {
        array.append(.int(value))
    }

    mutating func encode(_ value: UInt8) throws {
        array.append(.int(value))
    }

    mutating func encode(_ value: UInt16) throws {
        array.append(.int(value))
    }

    mutating func encode(_ value: UInt32) throws {
        array.append(.int(value))
    }

    mutating func encode(_ value: UInt64) throws {
        array.append(.int(value))
    }
    
    mutating func encode<Value>(_ value: Value) throws where Value: Encodable {
        let encoded = try wrapEncodable(value, for: JsonKey(index: count))
        array.append(encoded ?? [:])
    }
    
    func nestedContainer<NestedKey: CodingKey>(keyedBy keyType: NestedKey.Type) -> KeyedEncodingContainer<NestedKey> {
        let newPath = codingPath + [JsonKey(index: self.count)]
        let object = array.appendObject()
        return KeyedEncodingContainer(
            NakedJsonKeyedEncodingContainer(encoder: encoder, object: object, codingPath: newPath)
        )
    }
    
    func nestedUnkeyedContainer() -> UnkeyedEncodingContainer {
        let newPath = codingPath + [JsonKey(index: self.count)]
        let array = array.appendArray()
        return NakedJsonUnkeyedEncodingContainer(encoder: encoder, array: array, codingPath: newPath)
    }
    
    func superEncoder() -> Encoder {
        let encoder = getEncoder(for: JsonKey(index: self.count))
        self.array.append(encoder)
        return encoder
    }
}
