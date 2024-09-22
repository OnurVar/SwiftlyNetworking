//
//  ApiError.swift
//
//
//  Created by Onur Var on 1.02.2023.
//

import Foundation

public enum ApiError: Error {
    case NoStatusCode
    case NetworkError(message: String)
    case BadResponse(statusCode: Int)
    case ServerError(statusCode: Int?, message: String?)
    case NoJsonDecoder
    case InvalidToken
    case BadDecoding(message: String)
    case BadURL
    case NoUrlExecutor
}

extension ApiError: LocalizedError {
    public var errorDescription: String? {
        return "Oops, something went wrong. Please try again later. \(self.errorMessage)"
    }

    private var errorMessage: String {
        switch self {
        case .NoStatusCode:
            return "[Error:1001]"
        case .NetworkError(let message):
            return "[Error:1002] [Message:\(message)]"
        case .BadResponse(let statusCode):
            return "[Error:1003] [Code:\(statusCode)]"
        case .ServerError(let statusCode, let message):
            if let statusCode {
                if let message {
                    return "[Error:1004] [Code:\(statusCode)] [Message:\(message)]"
                }
                return "[Error:1004] [Code:\(statusCode)]"
            }
            return "[Error:1004]"
        case .NoJsonDecoder:
            return "[Error:1006]"
        case .InvalidToken:
            return "[Error:1007]"
        case .BadDecoding(let message):
            return "[Error:1008] [Message:\(message)]"
        case .BadURL:
            return "[Error:1009]"
        case .NoUrlExecutor:
            return "[Error:1010]"
        }
    }
}
