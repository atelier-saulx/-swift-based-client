//
//  Error.swift
//  
//
//  Created by Alexander van der Werff on 31/08/2021.
//
 
enum BasedErrorCode: Int, Decodable {
    case functionError = 50001,
    authorizeFunctionError = 50002,
    noOservableCacheAvailable = 50003,
    observableFunctionError = 50004,
    observeCallbackError = 50005,
    functionNotFound = 40401,
    functionIsNotObservable = 40402,
    functionIsObservable = 40403,
    functionIsStream = 40404,
//    CannotStreamToObservableFunction = 40402,
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

//export type BasedErrorData<T extends BasedErrorCode = BasedErrorCode> = {
//route: BasedFunctionRoute
//message: string
//code: T
//statusCode: number
//statusMessage: string
//    requestId?: number
//    observableId?: number
//    err?: BasedError<T>
//}

struct BasedErrorData: Decodable {
    let code: BasedErrorCode
    let message: String
    let statusMessage: String
}


public enum BasedError: Error {
    case
        authorizeFunctionError(message: String?),
        functionError(message: String?),
        missingToken(message: String?),
        noValidURL(message: String?),
        uploadError(message: String?),
        other(message: String?)
}

extension BasedError {
    static func from(_ errorString: String) -> Self {
        guard let errorData = errorString.data(using: .utf8)
        else {
            return .other(message: "Something went wrong")
        }
        let json = try? JSONDecoder().decode(BasedErrorData.self, from: errorData)
        
        //
        return BasedError.other(message: "")
    }
}
