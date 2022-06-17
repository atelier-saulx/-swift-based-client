import XCTest
@testable import NakedJson

final class JsonLiteralTests: XCTestCase {
    func testNull() throws {
        let value = Json.null
        XCTAssertEqual(value, nil)
    }
    
    func testString() throws {
        let value = Json.string("Test")
        XCTAssertEqual(value, "Test")
    }
    
    func testStringIterpolation() throws {
        let content = "Test"
        let value = Json.string("Test")
        XCTAssertEqual(value, "\(content)")
    }
    
    func testInt() throws {
        let value = Json.int(5)
        XCTAssertEqual(value, 5)
    }
    
    func testDouble() throws {
        let value = Json.double(5.5)
        XCTAssertEqual(value, 5.5)
    }
    
    func testBool() throws {
        let value = Json.bool(true)
        XCTAssertEqual(value, true)
    }
    
    func testArray() throws {
        let value = Json.array([.null, .int(5)])
        XCTAssertEqual(value, [nil, 5])
    }
    
    func testObject() throws {
        let value = Json.object(["test": Json.null])
        XCTAssertEqual(value, ["test": nil])
    }
}
