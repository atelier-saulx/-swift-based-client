//
//  Based+Request.swift
//  
//
//  Created by Alexander van der Werff on 26/11/2021.
//

import Foundation
import NakedJson

typealias RequestId = Int
typealias RequestCallbacks = Dictionary<RequestId, RequestCallback>

struct RequestCallback {
    let resolve: (Data) -> Void
    let reject: (Error) -> Void
}

var requestIdCnt: Int = 0

actor Callbacks {
    var requestIdCnt: Int = 0
    var requestCallbacks = RequestCallbacks()
    
    func addCallback(cb: RequestCallback, with id: RequestId) {
        requestCallbacks[id] = cb
    }
    
    func fetchCallback(with id: RequestId) -> RequestCallback? {
        requestCallbacks[id]
    }
    
    func removeCallback(with id: RequestId) {
        requestCallbacks.removeValue(forKey: id)
    }
}

extension Based {
    
    func addRequest(
        type: RequestType,
        payload: Json = nil,
        continuation: CheckedContinuation<Data, Error>,
        name: String
    ) {
        requestIdCnt += 1
        let id = requestIdCnt
        
        let cb = RequestCallback(resolve: { continuation.resume(returning: $0) }, reject: continuation.resume(throwing:))
        
        Task {
            await callbacks.addCallback(cb: cb, with: id)
        }

        if (type == .call) {
            addToMessages(FunctionCallMessage(id: id, name: name, payload: payload))
        } else {
            addToMessages(RequestMessage(requestType: type, id: id, payload: payload))
        }
    }
    
    
    func incomingRequest(_ data: [Json]) async {
        dataInfo("\(data)")
        
        guard
            let id = data[1].intValue,
            let cb = await callbacks.fetchCallback(with: id),
            let jsonData = try? encoder.encode(data[2])
        else { dataInfo("No id for data message"); return }
        
        await callbacks.removeCallback(with: id)
        
        guard data.count <= 3 else {
            if
                let errorObject = ErrorObject(from: data[3]) {
                
                cb.reject(BasedError.from(errorObject))

            } else {
                cb.reject(BasedError.other(message: "Something unexpected happened"))
            }
            return
        }
        
        cb.resolve(jsonData)

    }

}
