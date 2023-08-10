//
//  CallbacksStore.swift
//  
//
//  Created by Alexander van der Werff on 01/01/2023.
//

import Foundation

struct CallbacksStore<K: Hashable, V: Sendable> {
    private var callbacks: [K: V] = [:]
    mutating func add(callback: V, id: K) {
        callbacks[id] = callback
    }
    func fetch(id: K) -> V? {
        callbacks[id]
    }
    mutating func remove(id: K) {
        callbacks.removeValue(forKey: id)
    }
    func perform(_ closure: @escaping (K, V) -> ()) {
        callbacks.forEach { (key: K, value: V) in
            closure(key, value)
        }
    }
    func count() -> Int {
        callbacks.count
    }
}
