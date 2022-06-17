extension Json: ExpressibleByNilLiteral {
    public init(nilLiteral: ()) {
        self = .null
    }
}

extension Json: ExpressibleByStringLiteral {
    public init(stringLiteral value: String) {
        self = .string(value)
    }
}

extension Json: ExpressibleByStringInterpolation {
}

extension Json: ExpressibleByBooleanLiteral {
    public init(booleanLiteral value: Bool) {
        self = .bool(value)
    }
}

extension Json: ExpressibleByIntegerLiteral {
    public init(integerLiteral value: Int) {
        self = .int(value)
    }
}

extension Json: ExpressibleByFloatLiteral {
    public init(floatLiteral value: Double) {
        self = .double(value)
    }
}

extension Json: ExpressibleByArrayLiteral {
    public init(arrayLiteral elements: Json...) {
        self = .array(elements)
    }
}

extension Json: ExpressibleByDictionaryLiteral {
    public init(dictionaryLiteral elements: (String, Json)...) {
        self = .object(.init(uniqueKeysWithValues: elements))
    }
}
