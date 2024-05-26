//
//  URLRequestExecutor.swift
//
//
//  Created by Onur Var on 26.05.2024.
//

import Foundation

public struct URLRequestExecutor: URLRequestExecutorProtocol {
    // MARK: Variables

    private let urlRequest: URLRequest
    private let session: URLSession
    private let networkLogger: NetworkLoggerProtocol?

    // MARK: Life Cycle

    public init(
        withUrlRequest urlRequest: URLRequest,
        withSession session: URLSession,
        withNetworkLogger networkLogger: NetworkLoggerProtocol?
    ) {
        self.urlRequest = urlRequest
        self.session = session
        self.networkLogger = networkLogger
    }

    // MARK: Methods

    public func execute() async throws -> (Data, URLResponse) {
        do {
            let (data, response) = try await session.data(for: urlRequest)
            networkLogger?.log(data: data, response: response)
            return (data, response)
        } catch {
            networkLogger?.log(error: error)
            throw ApiError.NetworkError(message: error.localizedDescription)
        }
    }
}
