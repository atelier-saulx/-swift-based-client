//
//  File.swift
//  
//
//  Created by Alexander van der Werff on 01/02/2022.
//

import Foundation
import Combine
import XCTest

@testable import BasedClient

final class MessageManagerTest: XCTestCase {
    
    private var sut: MessageManager!
    private var spyWebSocket: SpyWebSocket!
    private var anyCancellable: AnyCancellable?
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        spyWebSocket = SpyWebSocket()
    }
    
    override func tearDownWithError() throws {
        sut = nil
        spyWebSocket = nil
        try super.tearDownWithError()
    }
    
    func testAddingAndSendingMessages() async {
        spyWebSocket.connected = true
        let messages = Messages()
        sut = MessageManager(messages: messages, socket: spyWebSocket)
    
        await sut.addMessage(StubMessage.random())
        await sut.addMessage(StubMessage.random())
        await sut.sendAllMessages()
        
        await sut.addMessage(StubMessage.random())
        
        XCTAssertEqual(self.spyWebSocket.invokedSendCount, 1, "One message should still be in the queue")
        
        let count = await self.sut.messageCount()
        XCTAssertEqual(count, 1, "One message should be ready for sending")
        let activityCount = await self.sut.activityCount()
        XCTAssertEqual(activityCount, 0, "All tasks should be completed")
    }
    
}
