import Foundation

struct NakedJsonSingleValueEncodingContainer: SingleValueEncodingContainer, ConvertingEncoder {
    var codingPath: [CodingKey]
    var encoder: NakedJsonEncoderImpl
    
    mutating func encodeNil() throws {
        encoder.singleValue = .null
    }
    
    mutating func encode(_ value: Bool) throws {
        encoder.singleValue = .bool(value)
    }
    
    mutating func encode(_ value: String) throws {
        encoder.singleValue = .string(value)
    }
    
    mutating func encode(_ value: Double) throws {
        encoder.singleValue = .double(value)
    }
    
    mutating func encode(_ value: Float) throws {
        encoder.singleValue = .double(value)
    }
    
    mutating func encode(_ value: Int) throws {
        encoder.singleValue = .int(value)
    }
    
    mutating func encode(_ value: Int8) throws {
        encoder.singleValue = .int(value)
    }
    
    mutating func encode(_ value: Int16) throws {
        encoder.singleValue = .int(value)
    }
    
    mutating func encode(_ value: Int32) throws {
        encoder.singleValue = .int(value)
    }
    
    mutating func encode(_ value: Int64) throws {
        encoder.singleValue = .int(value)
    }
    
    mutating func encode(_ value: UInt) throws {
        encoder.singleValue = .int(value)
    }
    
    mutating func encode(_ value: UInt8) throws {
        encoder.singleValue = .int(value)
    }
    
    mutating func encode(_ value: UInt16) throws {
        encoder.singleValue = .int(value)
    }
    
    mutating func encode(_ value: UInt32) throws {
        encoder.singleValue = .int(value)
    }
    
    mutating func encode(_ value: UInt64) throws {
        encoder.singleValue = .int(value)
    }
    
    mutating func encode<Value>(_ value: Value) throws where Value: Encodable {
        encoder.singleValue = try wrapEncodable(value, for: nil)
    }
}
