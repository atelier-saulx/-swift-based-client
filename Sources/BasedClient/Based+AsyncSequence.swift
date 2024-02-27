import Foundation
import NakedJson

enum SubscriptionType {
    case
        query(Query),
        `func`(_ name: String, _ payload: Json)
}

extension Based {
    
    public func subscribe<Payload: Encodable, Element: Decodable>(name: String, payload: Payload) throws -> AsyncThrowingStream<Element, Error> {
        let encoder = NakedJsonEncoder()
        
        let jsonPayload = try encoder.encode(payload)
        
        return basedAsyncThrowingStream(type: .func(name, jsonPayload), based: self)
    }
    
    private func basedAsyncThrowingStream<Element: Decodable>(type: SubscriptionType, based: Based) -> AsyncThrowingStream<Element, Error> {
        AsyncThrowingStream { continuation in

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
            
            let callback: ObserveCallback = { dataString, checksum, errorString, observeId in
                guard
                    let data = dataString.data(using: .utf8),
                    errorString.isEmpty
                else {
                    let error = BasedError.from(errorString)
                    continuation.finish(throwing: error)
                    return
                }
                do {
                    let result = try based.decoder.decode(Element.self, from: data)
                    continuation.yield(result)
                } catch {
                    continuation.finish(throwing: error)
                }
            }
            
            do {
                
                let id = try Current.basedClient.observe(name: name, payload: payload.description, callback: callback)
                
                continuation.onTermination = { @Sendable status in
                    Current.basedClient.unobserve(observeId: id)
                    dataInfo("Stream terminated with status \(status) and should unobserve \(id)")
                }
                
            } catch {
                continuation.finish(throwing: error)
            }
        }
    }
}
