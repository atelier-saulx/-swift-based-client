import XCTest
@testable import BasedClient

final class BasedClientTests: XCTestCase {
    
    private var sut: BasedClient!
    private var mockCClient: MockBasedCClient!
    private var mockGetCallbacks: GetCallbackStore!
    private var mockFuncCallbacks: FunctionCallbackStore!
    private var mockObserveCallbacks: ObserveCallbackStore!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        Current = .mock
        mockCClient = MockBasedCClient()
        mockGetCallbacks = GetCallbackStore()
        mockFuncCallbacks = FunctionCallbackStore()
        mockObserveCallbacks = ObserveCallbackStore()
        Current.basedClient = .mock(mockCClient, mockGetCallbacks, mockFuncCallbacks, mockObserveCallbacks)
        sut = Current.basedClient
    }
    
    override func tearDownWithError() throws {
        Current = .mock
        mockCClient = nil
        mockGetCallbacks = nil
        mockFuncCallbacks = nil
        try super.tearDownWithError()
    }
    
    func testGet() async {
        let data = "true".makeCString()
        let error = "".makeCString()
        mockCClient.getCallbackParam = (data: data, error: error, subscriptionId: 1)
   
        let result: (String, String) = await withCheckedContinuation { continuation in
            Task {
                await sut.get(name: "name", payload: "{}") { d, e in
                    continuation.resume(returning: (d, e))
                }
                
            }
        }
        
        XCTAssertEqual(result.0, String(cString: data))
        XCTAssertEqual(result.1, String(cString: error))
        
        let count = await mockGetCallbacks.count()
        XCTAssertEqual(count, 0)
        
        data.deallocate()
        error.deallocate()
    }
    
    func testFunction() async {
        let data = "{\"root\":true}".makeCString()
        let error = "".makeCString()
        mockCClient.funcCallbackParam = (data: data, error: error, subscriptionId: 1)
        
        let result: (String, String) = await withCheckedContinuation { continuation in
            Task {
                await sut.function(name: "get", payload: "{}") { d, e in
                    continuation.resume(returning: (d, e))
                }
                
            }
        }
        
        XCTAssertEqual(result.0, String(cString: data))
        XCTAssertEqual(result.1, String(cString: error))
        
        let count = await mockFuncCallbacks.count()
        XCTAssertEqual(count, 0)
        
        data.deallocate()
        error.deallocate()
    }
    
    func testObserve() async {
        let data = "{\"data\":\"bla\"}".makeCString()
        let error = "".makeCString()
        mockCClient.observeCallbackParam = (data: data, error: error, subscriptionId: 1)
        
        let result: (String, String) = await withCheckedContinuation { continuation in
            Task {
                await sut.observe(name: "get", payload: "{}") { d, c, e, o in
                    continuation.resume(returning: (d, e))
                }
                
            }
        }
        
        XCTAssertEqual(result.0, String(cString: data))
        XCTAssertEqual(result.1, String(cString: error))
        
        let count1 = await mockObserveCallbacks.count()
        XCTAssertEqual(count1, 1)

        await sut.unobserve(observeId: 1)
        
        let count2 = await mockObserveCallbacks.count()
        XCTAssertEqual(count2, 0)
        
        data.deallocate()
        error.deallocate()
    }
}
