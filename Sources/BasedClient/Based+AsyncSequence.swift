import Foundation
import NakedJson

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
            Task {
                await storage.unsubscribe { id in
                    await Current.basedClient.unobserve(observeId: id)
                }
            }
        }
    }
    
    public struct BasedSequence<Element: Decodable>: AsyncSequence {
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
    
    public func subscribe<Element: Decodable>(query: Query, resultType: Element.Type = Element.self) -> BasedSequence<Element> {
        return BasedSequence(type: .query(query), based: self)
    }
    
    public func subscribe<Element: Decodable>(name: String, payload: Json = [:], resultType: Element.Type = Element.self) -> BasedSequence<Element> {
        return BasedSequence(type: .func(name, payload), based: self)
    }
    
    public func subscribe<Payload: Encodable, Element: Decodable>(name: String, payload: Payload, resultType: Element.Type = Element.self) throws -> BasedSequence<Element> {
        let encoder = NakedJsonEncoder()
        
        let jsonPayload = try encoder.encode(payload)
        
        return BasedSequence(type: .func(name, jsonPayload), based: self)
    }
    
}

enum SubscriptionType {
    case query(Query), `func`(_ name: String, _ payload: Json)
}
