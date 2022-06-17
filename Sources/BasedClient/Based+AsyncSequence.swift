import Foundation
import NakedJson

extension Based {
    actor BasedIteratorStorage<Element, Failure: Error> {
        typealias SubscriptionIdentifiers = (subscriptionId: SubscriptionId, subscriberId: SubscriberId)
        
        private var bufferedValues: [Result<Element, Failure>] = []
        private var waitingContinuation: CheckedContinuation<Result<Element, Failure>, Never>? = nil
        
        var isMutatingSubscribtion: Bool = false
        var subscriptionIdentifiers: SubscriptionIdentifiers?
        
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
        
        func subscribe(subscription: () async -> SubscriptionIdentifiers) async {
            guard isMutatingSubscribtion == false, subscriptionIdentifiers == nil else { return }
            
            isMutatingSubscribtion = true
            
            subscriptionIdentifiers = await subscription()
            
            isMutatingSubscribtion = false
        }
        
        func unsubscribe(_ unsubscription: (SubscriptionIdentifiers) async -> Void) async {
            guard isMutatingSubscribtion == false, let ids = subscriptionIdentifiers else { return }
            
            isMutatingSubscribtion = true
            
            await unsubscription(ids)
            
            isMutatingSubscribtion = false
            subscriptionIdentifiers = nil
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
            guard await storage.subscriptionIdentifiers == nil else { return }
            
            let name: String?
            let payload: Json
            
            switch type {
            case .query(let query):
                name = nil
                payload = .object(query.dictionary())
            case .func(let functionName, let functionPayload):
                name = functionName
                payload = functionPayload
            }
            
            let dataCallback: DataCallback = { [storage, based] data, checksum in
                do {
                    let result = try based.decoder.decode(Element.self, from: data)
                    await storage.enqueue(.success(result))
                } catch {
                    await storage.enqueue(.failure(error))
                }
            }
            
            let errorCallback: ErrorCallback = { [storage] error in
                await storage.enqueue(.failure(error))
            }
            
            await storage.subscribe {
                await based.addSubscriber(
                    payload: payload,
                    onData: dataCallback,
                    onError: errorCallback,
                    subscriptionId: type.generateSubscriptionId(),
                    name: name
                )
            }
        }
        
        public func next() async throws -> Element? {
            await subscribeIfNeeded()
            
            return try await storage.wait().get()
        }
        
        deinit {
            Task {
                await storage.unsubscribe { ids in
                    await based.removeSubscriber(subscriptionId: ids.subscriptionId, subscriberId: ids.subscriberId)
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
