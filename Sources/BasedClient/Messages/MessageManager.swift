//
//  MessageManager.swift
//  
//
//  Created by Alexander van der Werff on 01/02/2022.
//

import Foundation
import NakedJson

actor MessageManager {
    private let messages: Messages
    private let socket: WebSocket
    private let encoder = JSONEncoder()
    private var activeTasks = [String: Task<(), Error>]()
    
    init(messages: Messages, socket: WebSocket) {
        self.messages = messages
        self.socket = socket
    }
    
    func addMessage<Msg: Message>(_ message: Msg) async {
        await messages.add(message)
    }
    
    func sendAllMessages() async {
        guard socket.connected else { return }
        let uuid = UUID().uuidString
        let task = Task {
            guard Task.isCancelled == false else { return }
            let nakedEncoder = NakedJsonEncoder()
            
            let messages = try await messages.popAll().map { msg in
                try msg.encode(with: nakedEncoder)
            }
            let json = try encoder.encode(messages)
            if let jsonString = String(data: json, encoding: .utf8) {
                socket.send(message: .string(jsonString))
                socket.idleTimeout()
            }
            activeTasks[uuid] = nil
        }
        activeTasks[uuid] = task
        
        do {
            try await task.value
        } catch {
            print(error)
        }
    }
    
    func cancelAll() {
        activeTasks.values.forEach { $0.cancel() }
        activeTasks.removeAll()
    }
    
    func messageCount() async -> Int {
        await messages.messageCount()
    }
    
    func activityCount() async -> Int {
        activeTasks.count
    }
}
