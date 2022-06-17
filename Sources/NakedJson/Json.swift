
public enum Json {
    case null
    
    case string(String)
    case int(Int)
    case double(Double)
    case bool(Bool)
    
    case array([Json])
    case object([String: Json])
}

extension Json {
    @_disfavoredOverload
    @inline(__always)
    public static func int<Value: FixedWidthInteger>(_ value: Value) -> Self {
        .int(Int(value))
    }
    
    @_disfavoredOverload
    @inline(__always)
    public static func double(_ value: Float) -> Self {
        .double(Double(value))
    }
}

extension Json: Equatable {}
extension Json: Hashable {}
