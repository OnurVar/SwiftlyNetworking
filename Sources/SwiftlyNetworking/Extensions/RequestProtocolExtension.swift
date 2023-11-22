//
//  RequestProtocolExtension.swift
//
//
//  Created by Onur Var on 1.02.2023.
//

import Foundation

public extension RequestProtocol {
    // MARK: Methods

    private func getURL(withServerConfig serverConfig: ServerConfigProtocol) throws -> URL {
        var urlComponents = URLComponents()

        urlComponents.scheme = serverConfig.scheme
        urlComponents.host = serverConfig.host
        urlComponents.port = serverConfig.port
        urlComponents.path = rPath
        urlComponents.queryItems = rQueryParameter?.toQueryParameters()

        let characterSet = CharacterSet(charactersIn: "/+:").inverted
        urlComponents.percentEncodedQuery = urlComponents.percentEncodedQuery?.addingPercentEncoding(withAllowedCharacters: characterSet)

        guard let url = urlComponents.url else {
            throw ApiError.BadURL
        }

        return url
    }

    func getURLRequest(withServerConfig serverConfig: ServerConfigProtocol, withAuthToken authToken: String? = nil) throws -> URLRequest {
        // Get the URL
        let url = try getURL(withServerConfig: serverConfig)

        // Create the URLRequest
        var urlRequest = URLRequest(url: url)

        // Set HttpMethod
        urlRequest.httpMethod = rHttpMethod.rawValue

        // Set Headers
        self.rHeaders?.forEach { key, value in
            urlRequest.setValue(value, forHTTPHeaderField: key)
        }
        if let authToken {
            urlRequest.addValue("Bearer \(authToken)", forHTTPHeaderField: "Authorization")
        }

        // Set Body
        urlRequest.httpBody = rBody

        return urlRequest
    }
}
