
public protocol JsonConvertible {
    func asJson() throws -> Json
}

extension Json: JsonConvertible {
    public func asJson() throws -> Json {
        return self
    }
}
