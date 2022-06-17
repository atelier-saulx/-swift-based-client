import Foundation

extension Json: CustomStringConvertible {
    public var description: String {
        switch self {
        case .null:
            return "null"
        case let .string(value):
            return "\"\(value)\""
        case let .int(value):
            return "\(value)"
        case let .double(value):
            return "\(value)"
        case let .bool(value):
            return "\(value)"
        case let .array(value):
            return "[" + value.map(\.description).joined(separator: ",") + "]"
        case let .object(value):
            return "{" + value.map { "\"\($0.key)\":\($0.value.description)" }.joined(separator: ",") + "}"
        }
    }
}
