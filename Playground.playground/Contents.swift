import Foundation

func djb2(_ key: String, _ inputHash: Int32 = 5381) -> Int32 {
    let scalarStrings = key.unicodeScalars.map { $0.value }
    let value = scalarStrings.reversed().reduce(inputHash) {
        ($0 << 5) &+ $0 &+ Int32($1)
    }
    return value
}


let data = "true".data(using: .utf8)!

func decode<T: Decodable>(data: Data) -> T {
    let value = try! JSONDecoder().decode(T.self, from: data)
    return value
}
let result: Bool = decode(data: data)
print(result)
