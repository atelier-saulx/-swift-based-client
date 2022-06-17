import XCTest
@testable import NakedJson

final class JsonValueTests: XCTestCase {
    func testNull() throws {
        let value = Json.null
        XCTAssertEqual(value.isNull, true)
    }
    
    func testNotNull() throws {
        let value = Json.int(5)
        XCTAssertEqual(value.isNull, false)
    }
    
    func testString() throws {
        let value = Json.string("Test")
        XCTAssertEqual(value.stringValue, "Test")
    }
    
    func testNotString() throws {
        let value = Json.int(5)
        XCTAssertEqual(value.stringValue, nil)
    }
    
    func testInt() throws {
        let value = Json.int(5)
        XCTAssertEqual(value.intValue, 5)
    }
    
    func testNotInt() throws {
        let value = Json.null
        XCTAssertEqual(value.intValue, nil)
    }
    
    func testDouble() throws {
        let value = Json.double(5.5)
        XCTAssertEqual(value.doubleValue, 5.5)
    }
    
    func testNotDouble() throws {
        let value = Json.null
        XCTAssertEqual(value.doubleValue, nil)
    }
    
    func testBool() throws {
        let value = Json.bool(true)
        XCTAssertEqual(value.boolValue, true)
    }
    
    func testNotBool() throws {
        let value = Json.string("a")
        XCTAssertEqual(value.boolValue, nil)
    }
    
    func testArray() throws {
        let value = Json.array([.null, .int(5)])
        XCTAssertEqual(value.arrayValue, [Json.null, Json.int(5)])
    }
    
    func testNotArray() throws {
        let value = Json.int(5)
        XCTAssertEqual(value.arrayValue, nil)
    }
    
    func testObject() throws {
        let value = Json.object(["test": Json.null])
        XCTAssertEqual(value.objectValue, ["test": Json.null])
    }
    
    func testNotObject() throws {
        let value = Json.null
        XCTAssertEqual(value.objectValue, nil)
    }
}
