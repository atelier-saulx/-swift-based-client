import XCTest
@testable import BasedClient

extension EmitterType where Payload == Int {
    static let testInt: Self = .init(name: "testInt")
}

extension EmitterType where Payload == Void {
    static let testVoid: Self = .init(name: "testVoid")
}

final class EmitterTests: XCTestCase {
    
    private var sut: Emitter!
    
    override func setUp() {
        super.setUp()
        sut = Emitter()
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }
    
    func testOnceEvent() {
        let expectation = self.expectation(description: "singe once event")
        
        sut.once(.testInt) { arg in
            XCTAssertEqual(arg, 1, "Should be the emitted value")
            expectation.fulfill()
        }
        
        sut.emit(type: .testInt, 1)
        
        waitForExpectations(timeout: 2) { error in
            print("Error: \(String(describing: error?.localizedDescription))")
        }
    }
    
    func testOnEvent() {
        let expectation = self.expectation(description: "singe on event")
        
        sut.on(.testInt) { arg in
            XCTAssertEqual(arg, 1, "Should be the emitted value")
            expectation.fulfill()
        }
        
        sut.emit(type: .testInt, 1)
        
        waitForExpectations(timeout: 2) { error in
            print("Error: \(String(describing: error?.localizedDescription))")
        }
    }
    
    func testOnNoArgumentsEvent() {
        let expectation = self.expectation(description: "singe on event and no arguments")
        
        sut.on(.testVoid) {
            expectation.fulfill()
        }
        
        sut.emit(type: .testVoid)
        
        waitForExpectations(timeout: 2) { error in
            print("Error: \(String(describing: error?.localizedDescription))")
        }
    }
    
    func testOnceEventWithMultipleEmits() {
        let expectation = self.expectation(description: "singe once event")
        
        var onceCount = 0
        
        sut.once(.testInt) { arg in
            XCTAssertEqual(arg, 1, "Should be the emitted value")
            onceCount += 1
        }
        
        sut.on(.testInt) { arg in
            if arg == 3 && onceCount == 1 {
                expectation.fulfill()
            }
        }
        
        sut.emit(type: .testInt, 1)
        sut.emit(type: .testInt, 2)
        sut.emit(type: .testInt, 3)
        
        waitForExpectations(timeout: 2) { error in
            print("Error: \(String(describing: error?.localizedDescription))")
        }
    }
    
}
