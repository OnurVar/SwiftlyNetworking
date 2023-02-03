//
//  NetworkLoader.swift
//
//
//  Created by Onur Var on 1.02.2023.
//

import Foundation

public class NetworkLoader {
    // MARK: Variables

    public var delegate: NetworkLoaderDelegateProtocol?

    // MARK: Life Cycle

    public init() {}
}

extension NetworkLoader: NetworkLoaderProtocol {
    public func sendRequest(urlRequest: URLRequest) async throws -> Data {
        // Get the NetworkLogger
        let networkLogger = delegate?.getLogger(urlRequest: urlRequest)

        // Execute
        let (data, response) = try await urlRequest.execute(withNetworkLogger: networkLogger)

        // Check if StatusCode exist
        guard let statusCode = (response as? HTTPURLResponse)?.statusCode else {
            throw ApiError.NoStatusCode
        }

        // Check if StatusCode is between 200 ... 299
        guard let statusCode = (response as? HTTPURLResponse)?.statusCode, (200 ... 299).contains(statusCode) else {
            // Something failed, Check the data
            guard let errorMessage = delegate?.parseErrorMessage(data: data) else {
                throw ApiError.BadResponse(statusCode: statusCode)
            }

            // Check if we receive an InvalidToken error in the errorMessage
            if let isInvalidToken = delegate?.checkInvalidTokenResponse(errorMessage: errorMessage), isInvalidToken {
                throw ApiError.InvalidToken
            }

            throw ApiError.ServerError(statusCode: statusCode, message: errorMessage)
        }

        return data
    }
}
