extension Json {
    public var isNull: Bool {
        guard case .null = self else {
            return false
        }
        return true
    }
    
    public var stringValue: String? {
        guard
            case let .string(value) = self
        else { return nil }
        
        return value
    }
    
    public var intValue: Int? {
        guard
            case let .int(value) = self
        else { return nil }
        
        return value
    }
    
    public var doubleValue: Double? {
        guard
            case let .double(value) = self
        else { return nil }
        
        return value
    }
    
    public var boolValue: Bool? {
        guard
            case let .bool(value) = self
        else { return nil }
        
        return value
    }
    
    public var arrayValue: [Json]? {
        guard
            case let .array(value) = self
        else { return nil }
        
        return value
    }
    
    public var objectValue: [String: Json]? {
        guard
            case let .object(value) = self
        else { return nil }
        
        return value
    }
    
    var intArrayValue: [Int]? {
        guard
            let result = arrayValue?.map(\.intValue),
            result.allSatisfy({ $0 != nil })
        else { return nil }
        
        return result.compactMap { $0 }
    }
}
