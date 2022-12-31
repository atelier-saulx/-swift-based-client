import XCTest
@testable import BasedClient

final class BasedClientTests: XCTestCase {
    
    private var sut: BasedClient!
    private var mockCClient: MockBasedCClient!
    private var mockGetCallbacks: GetCallbackStore!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        Current = .mock
        mockCClient = MockBasedCClient()
        mockGetCallbacks = GetCallbackStore()
        Current.basedClient = .mock(mockCClient, mockGetCallbacks)
        sut = Current.basedClient
    }
    
    override func tearDownWithError() throws {
        Current = .mock
        mockCClient = nil
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
}
