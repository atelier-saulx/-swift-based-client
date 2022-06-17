//
//  ErrorObject.swift
//  
//
//  Created by Alexander van der Werff on 27/09/2021.
//

import Foundation
import NakedJson


/// ErrorObject returned from Based server
/// Example:
/// [
///     "message": "Unauthorized request",
///     "type": "AuthorizationError",
///     "auth": true,
///     "payload": ["documents": false, "id": "use22bd860"],
///     "name": "call users-observeId"])
/// ]
struct ErrorObject: Decodable {
    let type: String
    let message: String
    let name: String?
    let query: Json?
    let payload: Json?
    let auth: Bool?
    let code: String?
}

extension ErrorObject {
    // FIXME: Use just NakedDecoder
    init?(from data: Json) {
        guard let data = data.objectValue else {
            return nil
        }
        type = data["type"]?.stringValue ?? ""
        message = data["message"]?.stringValue ?? ""
        name = data["name"]?.stringValue
        query = data["query"]
        payload = data["payload"]
        auth = data["auth"]?.boolValue
        code = data["code"]?.stringValue
    }
}
