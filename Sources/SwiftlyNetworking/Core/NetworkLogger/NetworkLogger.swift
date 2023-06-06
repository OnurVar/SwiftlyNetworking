//
//  NetworkLogger.swift
//
//
//  Created by Onur Var on 1.02.2023.
//

import Foundation
import Logging

public class NetworkLogger {
    // MARK: Variables

    private let logger = Logger(label: "SwiftlyNetworking")
    private let request: URLRequest
    private let requestConfig: RequestConfigProtocol
    private let requestCreatedAt = Date()

    // MARK: Life Cycle

    public init(withURLRequest request: URLRequest, withRequestConfig requestConfig: RequestConfigProtocol) {
        self.request = request
        self.requestConfig = requestConfig
    }
}

extension NetworkLogger: NetworkLoggerProtocol {
    public func log(data: Data, response: URLResponse) {
        guard requestConfig.logRequest else {
            return
        }
        var isSuccessful = false
        var message = ""

        let timeDifference = Date().timeIntervalSince(requestCreatedAt) * 1000
        let urlAsString = request.url?.absoluteString ?? ""
        let method = request.httpMethod != nil ? "\(request.httpMethod ?? "")" : ""

        var statusCode = ""
        if let response = response as? HTTPURLResponse {
            statusCode = "\(response.statusCode)"
            isSuccessful = (200 ..< 300).contains(response.statusCode)
        }

        message = message + "Status: \(statusCode) \(Int(timeDifference))ms\n"
        message = message + "[\(method)] \(urlAsString)"

        if requestConfig.logRequestHeader {
            message = message + "\n-- Request Header --"
            for (key, value) in request.allHTTPHeaderFields ?? [:] {
                message = message + "\n\(key): \(value)"
            }
        }

        if requestConfig.logRequestBody {
            if let body = request.httpBody {
                message = message + "\n-- Request Body --\n"
                message = message + "\(String(data: body, encoding: .utf8) ?? "")"
            }
        }

        if requestConfig.logResponseHeader {
            message = message + "\n-- Response Header --"
            if let response = response as? HTTPURLResponse {
                for (key, value) in response.allHeaderFields {
                    message = message + "\n\(key): \(value)"
                }
            }
        }
        if requestConfig.logResponseBody {
            message = message + "\n-- Response Body --\n"
            message = message + "\(String(data: data, encoding: .utf8) ?? "")"
        }
        if isSuccessful {
            logger.info("\(message)")
        } else {
            logger.error("\(message)")
        }
    }

    public func log(error: Error) {
        guard requestConfig.logRequest else {
            return
        }
        var message = ""

        let timeDifference = Date().timeIntervalSince(requestCreatedAt) * 1000
        let urlAsString = request.url?.absoluteString ?? ""
        let method = request.httpMethod != nil ? "\(request.httpMethod ?? "")" : ""

        message = message + "Status: \(Int(timeDifference))ms\n"
        message = message + "[\(method)] \(urlAsString)"

        if requestConfig.logRequestHeader {
            message = message + "\n-- Request Header --"
            for (key, value) in request.allHTTPHeaderFields ?? [:] {
                message = message + "\n\(key): \(value)"
            }
        }

        if requestConfig.logRequestBody {
            if let body = request.httpBody {
                message = message + "\n-- Request Body --\n"
                message = message + "\(String(data: body, encoding: .utf8) ?? "")"
            }
        }

        message = message + "\n\n-- Error --\n"
        message = message + "\(error.localizedDescription)"

        logger.error("\(message)")
    }
}
