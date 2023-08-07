import Foundation
import NakedJson

enum SubscriptionType {
    case
        query(Query),
        `func`(_ name: String, _ payload: Json)
}

extension Based {
    
    actor BasedIteratorStorage<Element, Failure: Error> {
        
        private var bufferedValues: [Result<Element, Failure>] = []
        private var waitingContinuation: CheckedContinuation<Result<Element, Failure>, Never>? = nil
        
        var isMutatingSubscribtion: Bool = false
        var subscriptionIdentifier: ObserveId?
        
        func enqueue(_ result: Result<Element, Failure>) {
            if let continuation = waitingContinuation {
                continuation.resume(returning: result)
                self.waitingContinuation = nil
            } else {
                bufferedValues.append(result)
            }
        }
        
        private func dequeue() -> Result<Element, Failure>? {
            guard bufferedValues.isEmpty == false else {
                return nil
            }
            return bufferedValues.removeFirst()
        }
        
        func wait() async -> Result<Element, Failure> {
            if let bufferedElement = dequeue() {
                return bufferedElement
            }
            
            guard waitingContinuation == nil else {
                fatalError("Subscription already has waiting continuation")
            }
            
            let result = await withCheckedContinuation { continuation in
                waitingContinuation = continuation
            }
            
            waitingContinuation = nil
            
            return result
        }
        
        func subscribe(subscription: () async -> ObserveId) async {
            guard isMutatingSubscribtion == false, subscriptionIdentifier == nil else { return }
            
            isMutatingSubscribtion = true
            
            subscriptionIdentifier = await subscription()
            
            isMutatingSubscribtion = false
        }
        
        func unsubscribe(_ unsubscription: (ObserveId) async -> Void) async {
            guard isMutatingSubscribtion == false, let ids = subscriptionIdentifier else { return }
            
            isMutatingSubscribtion = true
            
            await unsubscription(ids)
            
            isMutatingSubscribtion = false
            subscriptionIdentifier = nil
        }
    }
    
    public final class BasedIterator<Element: Decodable>: AsyncIteratorProtocol {
        let type: SubscriptionType
        let based: Based
        let storage: BasedIteratorStorage<Element, Error> = .init()
        
        init(type: SubscriptionType, based: Based) {
            self.type = type
            self.based = based
        }
        
        func subscribeIfNeeded() async {
            guard await storage.subscriptionIdentifier == nil else { return }
            
            let name: String
            let payload: Json
            
            switch type {
            case .query(let query):
                name = "based-db-observe"
                payload = .object(query.dictionary())
            case .func(let functionName, let functionPayload):
                name = functionName
                payload = functionPayload
            }
            
            let callback: ObserveCallback = { [storage, based] dataString, checksum, errorString, observeId in
                guard
                    let data = dataString.data(using: .utf8),
                    errorString.isEmpty
                else {
                    let error = BasedError.from(errorString)
                    Task { await storage.enqueue(.failure(error)) }
                    return
                }
                do {
                    let result = try based.decoder.decode(Element.self, from: data)
                    Task { await storage.enqueue(.success(result)) }
                } catch {
                    Task { await storage.enqueue(.failure(error)) }
                }
            }
            
            await storage.subscribe {
                await Current.basedClient.observe(name: name, payload: payload.description, callback: callback)
            }
        }
        
        public func next() async throws -> Element? {
            await subscribeIfNeeded()
            
            return try await storage.wait().get()
        }
        
        deinit {
            Task { [weak storage] in
                await storage?.unsubscribe { id in
                    await Current.basedClient.unobserve(observeId: id)
                }
            }
        }
    }
    
    public struct BasedAsyncSequence<Element: Decodable>: AsyncSequence {
        let type: SubscriptionType
        let based: Based
        
        init(type: SubscriptionType, based: Based) {
            self.type = type
            self.based = based
        }
        
        public func makeAsyncIterator() -> BasedIterator<Element> {
            BasedIterator(type: type, based: based)
        }
    }
    
    /// This function returns an instance of "BasedAsyncSequence" class that is initialized with the type of the sequence being ".query(query)"
    ///
    /// - Parameters:
    ///    - query: an instance of the Query
    ///    - resultType: the type of the elements that will be returned in the sequence. It is set to "Element.self" by default
    ///
    /// - Returns:
    ///     A BasedAsyncSequence object containing the subscribed sequence.
    public func subscribe<Element: Decodable>(query: Query, resultType: Element.Type = Element.self) -> BasedAsyncSequence<Element> {
        return BasedAsyncSequence(type: .query(query), based: self)
    }
    
    /**
     Subscribe to a specific sequence and return a BasedAsyncSequence object.
     
     - Parameters:
        - name: A string representing the name of the sequence to subscribe to.
        - payload: A JSON object containing additional information to be sent with the subscription request. Default value is an empty dictionary.
        - resultType: The type of the decodable element. Default value is the Element.self.
     
     - Returns:
        A BasedAsyncSequence object containing the subscribed sequence.
     */
    public func subscribe<Element: Decodable>(name: String, payload: Json = [:], resultType: Element.Type = Element.self) -> BasedAsyncSequence<Element> {
        return BasedAsyncSequence(type: .func(name, payload), based: self)
    }
    
    /**
     Subscribe to a specific sequence and return a BasedAsyncSequence object.
     
     - Parameters:
        - name: A string representing the name of the sequence to subscribe to.
        - payload: An object conforming to the Encodable protocol, representing additional information to be sent with the subscription request.
        - resultType: The type of the decodable element. Default value is the Element.self.
     
     - Throws:
        An error if the encoding of the payload object fails.
     
     - Returns:
        A BasedAsyncSequence object containing the subscribed sequence.
     */
    public func subscribe<Payload: Encodable, Element: Decodable>(name: String, payload: Payload, resultType: Element.Type = Element.self) throws -> BasedAsyncSequence<Element> {
        let encoder = NakedJsonEncoder()
        
        let jsonPayload = try encoder.encode(payload)
        
        return BasedAsyncSequence(type: .func(name, jsonPayload), based: self)
    }
    
}

public struct BasedAsyncSequence<Element>: AsyncSequence {
    public final class Iterator: AsyncIteratorProtocol {
        private var produceNext: () async throws -> Element?
        
        init<Upstream: AsyncIteratorProtocol>(upstream: Upstream) where Element == Upstream.Element {
            var mutableCopy = upstream
            produceNext = {
                try await mutableCopy.next()
            }
        }
        
        public func next() async throws -> Element? {
            guard !Task.isCancelled else {
                return nil
            }
            return try await produceNext()
        }
    }
    
    private let makeIterator: () -> Iterator
    
    init<Upstream: AsyncSequence>(upstream: Upstream) where Element == Upstream.Element {
        makeIterator = {
            Iterator(upstream: upstream.makeAsyncIterator())
        }
    }
    
    public func makeAsyncIterator() -> Iterator {
        makeIterator()
    }
}

extension AsyncSequence {
    public func asBasedAsyncSequence() -> BasedAsyncSequence<Element> {
        .init(upstream: self)
    }
}
