//
//  RequestProtocolExtension.swift
//
//
//  Created by Onur Var on 1.02.2023.
//

import Foundation
import SwiftlyHelper

extension RequestProtocol {
    // MARK: Methods

    func getURL(config: ServerConfigProtocol) throws -> URL {
        var urlComponents = URLComponents()
        
        urlComponents.scheme = config.scheme
        urlComponents.host = config.host
        urlComponents.path = path
        urlComponents.queryItems = queryParameter?.toQueryParameters()

        guard let url = urlComponents.url else {
            throw ApiError.BadURL
        }
        
        return url
    }

    func getRequest(config: ServerConfigProtocol, authToken: String? = nil) throws -> URLRequest {
        let url = try getURL(config: config)
        
        var urlRequest = URLRequest(url: url)
        // Set HttpMethod
        urlRequest.httpMethod = httpMethod
        
        // Set Headers
        urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.addValue("application/json", forHTTPHeaderField: "Accept")
        if let authToken = authToken {
            urlRequest.addValue("Bearer \(authToken)", forHTTPHeaderField: "Authorization")
        }
        
        // Set Body
        urlRequest.httpBody = body?.toJSONData()
        
        return urlRequest
    }
}
