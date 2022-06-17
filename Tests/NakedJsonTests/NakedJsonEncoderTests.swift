import XCTest
@testable import NakedJson

private struct User: Encodable {
    let id: Int
    let name: String
    let age: Double
    let isMerried: Bool
}

final class NakedJsonEncoderTests: XCTestCase {
    let encoder = NakedJsonEncoder()
    
    func testNull() throws {
        let value: String? = nil
        let json = try encoder.encode(value)
        
        XCTAssertEqual(json, .null)
    }
    
    func testString() throws {
        let value: String = "Hi!"
        let json = try encoder.encode(value)
        
        XCTAssertEqual(json, .string("Hi!"))
    }
    
    func testInt() throws {
        let value: Int = 5
        let json = try encoder.encode(value)
        
        XCTAssertEqual(json, .int(5))
    }
    
    func testDouble() throws {
        let value: Double = 5.5
        let json = try encoder.encode(value)
        
        XCTAssertEqual(json, .double(5.5))
    }
    
    func testBool() throws {
        let value = true
        let json = try encoder.encode(value)
        
        XCTAssertEqual(json, .bool(true))
    }
    
    func testArray() throws {
        let value: [Int] = [1, 2, 3, 4]
        let json = try encoder.encode(value)
        
        XCTAssertEqual(json, [1, 2, 3, 4])
    }
    
    func testObject() throws {
        let george = User(
            id: 1,
            name: "George",
            age: 27.3,
            isMerried: true
        )
        
        let json = try encoder.encode(george)
        
        XCTAssertEqual(json, [
            "id": 1,
            "name": "George",
            "age": 27.3,
            "isMerried": true
        ])
    }
    
    func testObjectArray() throws {
        let users = [
            User(id: 1, name: "Blob", age: 23, isMerried: false),
            User(id: 2, name: "Blob Jr.", age: 21, isMerried: true),
        ]
        
        let json = try encoder.encode(users)
        
        XCTAssertEqual(json, [
            ["id": 1, "name": "Blob", "age": 23.0, "isMerried": false],
            ["id": 2, "name": "Blob Jr.", "age": 21.0, "isMerried": true],
        ])
    }
    
    func testDate() throws {
        let date = Date(timeIntervalSince1970: 1653219230)
        
        let json = try encoder.encode(date)
        
        XCTAssertEqual(json, .double(date.timeIntervalSinceReferenceDate))
    }
    
    func testURL() throws {
        let url = URL(string: "https://github.com/")!
        
        let json = try encoder.encode(url)
        
        XCTAssertEqual(json, "https://github.com/")
    }
    
    
    public struct Merged2<V1: Encodable, V2: Encodable>: Encodable {
        let value1: V1
        let value2: V2
        
        public func encode(to encoder: Encoder) throws {
            try value1.encode(to: encoder)
            try value2.encode(to: encoder)
        }
    }
    
    struct Test1: Encodable {
        var field1: String
    }
    
    struct Test2: Encodable {
        var field2: String
    }
    
    func testMerge() throws {
        let value = Merged2(value1: Test1(field1: "test"), value2: Test2(field2: "lol"))
        
        let json = try encoder.encode(value)
        
        XCTAssertEqual(json, ["field1": "test", "field2": "lol"])
    }
    
}
