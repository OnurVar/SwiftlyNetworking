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
    case UnknownNetworkError
    case NoJsonDecoder
    case InvalidToken
    case BadDecoding(message: String)
    case BadURL
}

extension ApiError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .NoStatusCode:
            return "Error [1001]"
        case .NetworkError(let message):
            return "Error [1002] \(message)"
        case .BadResponse(let statusCode):
            return "Error [1003] \(statusCode)"
        case .ServerError(let statusCode, let message):
            return "Error [1004] \(statusCode ?? 0) - \(message ?? "")]"
        case .UnknownNetworkError:
            return "Error [1005]"
        case .NoJsonDecoder:
            return "Error [1006]"
        case .InvalidToken:
            return "Error [1007]"
        case .BadDecoding(let message):
            return "Error [1008] \(message)"
        case .BadURL:
            return "Error [1009]"
        }
    }
}
