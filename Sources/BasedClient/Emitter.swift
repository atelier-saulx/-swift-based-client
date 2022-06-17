//
//  Emitter.swift
//  
//
//  Created by Alexander van der Werff on 04/09/2021.
//

import Foundation

#if os(Linux)
import Dispatch
#endif

fileprivate class Listener<T> {
    let listener: (T) -> Void
    let once: Bool

    init(_ listener: @escaping (T) -> Void, once: Bool) {
        self.once = once
        self.listener = listener
    }
}

struct EmitterType<Payload> {
    let name: String
}

extension EmitterType where Payload == String? {
    static let auth: Self = .init(name: "auth")
}

extension EmitterType where Payload == Void {
    static let disconnect: Self = .init(name: "disconnect")
    static let reconnect: Self = .init(name: "reconnect")
    static let connect: Self = .init(name: "connect")
}

class Emitter {
    
    var listeners: [String: [AnyObject]] = [:]

    func emit(type: EmitterType<Void>) {
        listeners[type.name]?.forEach {
            emit(type, $0, ())
        }
    }
    
    func emit<Payload>(type: EmitterType<Payload>, _ val: Payload) {
        listeners[type.name]?.forEach {
            emit(type, $0, val)
        }
    }
    
    private func emit<Payload>(_ type: EmitterType<Payload>, _ listener: Any, _ val: Payload) {
        guard
            let wrapper = listener as? Listener<Payload>
        else { return }
        
        wrapper.listener(val)
        
        if wrapper.once {
            removeListener(type, wrapper)
        }
    }

    func on<Payload>(_ type: EmitterType<Payload>, _ fn: @escaping (Payload) -> ()) {
        on(type, .init(fn, once: false))
    }
    
    func once<Payload>(_ type: EmitterType<Payload>, _ fn: @escaping (Payload) -> ()) {
        on(type, .init(fn, once: true))
    }
    
    private func on<Payload>(_ type: EmitterType<Payload>, _ listener: Listener<Payload>) {
        if listeners[type.name] == nil {
            listeners[type.name] = []
        }
        listeners[type.name]?.append(listener)
    }

    func removeAllListeners() {
        listeners = [:]
    }

    private func removeListener<T>(_ type: EmitterType<T>, _ listener: Listener<T>) {
        listeners[type.name]?.removeAll { l in
            l === listener
        }
        if listeners[type.name, default: []].isEmpty {
            listeners.removeValue(forKey: type.name)
        }
    }

}
