//
//  NetworkLogger.swift
//
//
//  Created by Onur Var on 1.02.2023.
//

import Foundation
import Logging

class NetworkLogger {
    let logger = Logger(label: "NetworkLogger")

    let request: URLRequest
    let config: RequestConfigProtocol
    let requestCreatedAt: Date

    init(withURLRequest request: URLRequest, withConfig config: RequestConfigProtocol) {
        self.request = request
        self.config = config
        self.requestCreatedAt = .init()
    }

    func log(data: Data, response: URLResponse) {
        guard config.logRequest else {
            return
        }
        var message = ""

        let timeDifference = Date().timeIntervalSince(requestCreatedAt) * 1000
        let urlAsString = request.url?.absoluteString ?? ""
        let method = request.httpMethod != nil ? "\(request.httpMethod ?? "")" : ""

        var statusCode = ""
        if let response = response as? HTTPURLResponse {
            statusCode = "\(response.statusCode)"
        }

        message = message + "Status: \(statusCode) \(Int(timeDifference))ms\n"
        message = message + "[\(method)] \(urlAsString)"

        if config.logRequestHeader {
            message = message + "\n-- Request Header --"
            for (key, value) in request.allHTTPHeaderFields ?? [:] {
                message = message + "\n\(key): \(value)"
            }
        }

        if config.logRequestBody {
            if let body = request.httpBody {
                message = message + "\n-- Request Body --\n"
                message = message + "\(String(data: body, encoding: .utf8) ?? "")"
            }
        }

        if config.logResponseHeader {
            message = message + "\n-- Response Header --"
            if let response = response as? HTTPURLResponse {
                for (key, value) in response.allHeaderFields {
                    message = message + "\n\(key): \(value)"
                }
            }
        }
        if config.logResponseBody {
            message = message + "\n-- Response Body --\n"
            message = message + "\(String(data: data, encoding: .utf8) ?? "")"
        }

        logger.info("\(message)")
    }

    func log(error: Error) {
        guard config.logRequest else {
            return
        }
        var message = ""

        let timeDifference = Date().timeIntervalSince(requestCreatedAt) * 1000
        let urlAsString = request.url?.absoluteString ?? ""
        let method = request.httpMethod != nil ? "\(request.httpMethod ?? "")" : ""

        message = message + "Status: \(Int(timeDifference))ms\n"
        message = message + "[\(method)] \(urlAsString)"

        if config.logRequestHeader {
            message = message + "\n-- Request Header --"
            for (key, value) in request.allHTTPHeaderFields ?? [:] {
                message = message + "\n\(key): \(value)"
            }
        }

        if config.logRequestBody {
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
