//
//  Error.swift
//  
//
//  Created by Alexander van der Werff on 31/08/2021.
//

public struct BasedErrorData: Decodable {
    public enum BasedServerErrorCode: Int, Decodable {
        case functionError = 50001,
             authorizeFunctionError = 50002,
             noOservableCacheAvailable = 50003,
             observableFunctionError = 50004,
             observeCallbackError = 50005,
             functionNotFound = 40401,
             functionIsNotObservable = 40402,
             functionIsObservable = 40403,
             functionIsStream = 40404,
             cannotStreamToObservableFunction = 40405,
             authorizeRejectedError = 40301,
             invalidPayload = 40001,
             payloadTooLarge = 40002,
             chunkTooLarge = 40003,
             unsupportedContentEncoding = 40004,
             noBinaryProtocol = 40005,
             lengthRequired = 41101,
             methodNotAllowed = 40501,
             rateLimit = 40029
    }
    let code: BasedServerErrorCode
    let message: String
    let statusMessage: String
}


public enum BasedError: Error {
    case
        serverError(data: BasedErrorData),
        missingToken(message: String?),
        noValidURL(message: String?),
        uploadError(message: String?),
        other(message: String?)
}

extension BasedError {
    /// Errors returned from the Based server
    static func from(_ errorString: String) -> Self {
        guard
            let data = errorString.data(using: .utf8),
            let errorData = try? JSONDecoder().decode(BasedErrorData.self, from: data)
        else {
            return .other(message: "Something unexpected went wrong")
        }
        
        return BasedError.serverError(data: errorData)
    }
}
