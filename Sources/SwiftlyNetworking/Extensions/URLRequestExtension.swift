//
//  URLRequestExtension.swift
//
//
//  Created by Onur Var on 3.02.2023.
//

import Foundation

public extension URLRequest {
    func execute(withNetworkLogger networkLogger: NetworkLoggerProtocol?) async throws -> (Data, URLResponse) {
        do {
            let (data, response) = try await URLSession.shared.data(for: self)
            networkLogger?.log(data: data, response: response)
            return (data, response)
        } catch {
            networkLogger?.log(error: error)
            throw ApiError.NetworkError(message: error.localizedDescription)
        }
    }
}
