//
//  ApiClient.swift
//
//
//  Created by Onur Var on 1.02.2023.
//

import Foundation

public class ApiClient<TokenType: Decodable>: ApiClientProtocol {
    // MARK: Variables

    public var delegate: ApiClientDelegateProtocol?
    private var responseParser: ResponseParserProtocol
    private var networkLoader: NetworkLoaderProtocol
    private var serverConfig: ServerConfigProtocol
    private let queue: DispatchQueue
    private let semaphore = DispatchSemaphore(value: 1)

    var requestCount = 0

    // MARK: Life Cycle

    public init(
        responseParser: ResponseParserProtocol,
        networkLoader: NetworkLoaderProtocol,
        serverConfig: ServerConfigProtocol,
        queue: DispatchQueue
    ) {
        self.responseParser = responseParser
        self.networkLoader = networkLoader
        self.serverConfig = serverConfig
        self.queue = queue
    }

    // MARK: Methods

    /// It sends the request to the server and returns the response object.
    /// The requests are executed in a serial queue.
    public func request<ResponseType: Decodable>(request: RequestProtocol, ResponseType: ResponseType.Type, TokenType: TokenType.Type) async throws -> ResponseType? {
        return try await withCheckedThrowingContinuation { continuation in
            queue.sync {
                semaphore.wait()
                Task {
                    do {
                        let response = try await executeRequestWithRetry(request: request, ResponseType: ResponseType, TokenType: TokenType)
                        semaphore.signal()
                        continuation.resume(returning: response)
                    } catch {
                        semaphore.signal()
                        continuation.resume(throwing: error)
                    }
                }
            }
        }
    }

    /// It sends the request to the server.
    /// The requests are executed in a serial queue.
    public func request(request: RequestProtocol, TokenType: TokenType.Type) async throws {
        return try await withCheckedThrowingContinuation { continuation in
            queue.sync {
                semaphore.wait()
                Task {
                    do {
                        try await executeRequestWithRetry(request: request, TokenType: TokenType)
                        semaphore.signal()
                        continuation.resume(returning: ())
                    } catch {
                        semaphore.signal()
                        continuation.resume(throwing: error)
                    }
                }
            }
        }
    }

    /// First, it tries to execute the request.
    /// If it fails due to InvalidToken error, It tries to refresh the token and retry the request
    private func executeRequestWithRetry<ResponseType: Decodable>(request: RequestProtocol, ResponseType: ResponseType.Type, TokenType: TokenType.Type) async throws -> ResponseType? {
        do {
            return try await performAndParseRequest(request: request, ResponseType: ResponseType)
        } catch ApiError.InvalidToken {
            try await refreshToken(TokenType: TokenType)
            return try await performAndParseRequest(request: request, ResponseType: ResponseType)
        } catch {
            throw error
        }
    }

    /// First, it tries to execute the request.
    /// If it fails due to InvalidToken error, It tries to refresh the token and retry the request
    private func executeRequestWithRetry(request: RequestProtocol, TokenType: TokenType.Type) async throws {
        do {
            return try await performAndParseRequest(request: request)
        } catch ApiError.InvalidToken {
            try await refreshToken(TokenType: TokenType)
            return try await performAndParseRequest(request: request)
        } catch {
            throw error
        }
    }

    /// First, it gets the URLRequest from the request object.
    /// Then, it sends the request to the server.
    /// Finally, it parses the response data and returns the response object.
    private func performAndParseRequest<ResponseType: Decodable>(request: RequestProtocol, ResponseType: ResponseType.Type) async throws -> ResponseType? {
        // Get the URLRequest
        let urlRequest = try request.getURLRequest(withServerConfig: serverConfig, withAuthToken: delegate?.getAuthToken())

        // Make the request, get the data
        let data = try await networkLoader.sendRequest(urlRequest: urlRequest)

        // Decode the data
        return try responseParser.parse(data: data, request: request, Type: ResponseType)
    }

    /// First, it gets the URLRequest from the request object.
    /// Then, it sends the request to the server.
    private func performAndParseRequest(request: RequestProtocol) async throws {
        // Get the URLRequest
        let urlRequest = try request.getURLRequest(withServerConfig: serverConfig, withAuthToken: delegate?.getAuthToken())

        // Make the request
        let _ = try await networkLoader.sendRequest(urlRequest: urlRequest)
    }

    private func refreshToken(TokenType: TokenType.Type) async throws {
        // Get the RefreshTokenRequest
        guard let request = delegate?.getRefreshTokenRequest() else {
            return
        }
        // Get the URLRequest
        let urlRequest = try request.getURLRequest(withServerConfig: serverConfig)

        // Make the request, get the data
        let data = try await networkLoader.sendRequest(urlRequest: urlRequest)

        // Decode the data
        let decodableToken = try responseParser.parse(data: data, request: request, Type: TokenType)

        // Notify the TokenDelegateProtocol
        delegate?.onTokenChange(decodableToken: decodableToken)
    }
}
