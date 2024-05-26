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
    var requestCount = 0

    // MARK: Life Cycle

    public init(
        responseParser: ResponseParserProtocol,
        networkLoader: NetworkLoaderProtocol,
        serverConfig: ServerConfigProtocol,
        queue: DispatchQueue? = nil
    ) {
        self.responseParser = responseParser
        self.networkLoader = networkLoader
        self.serverConfig = serverConfig

        if let queue {
            self.queue = queue
        } else {
            self.queue = DispatchQueue(label: "com.onurvar.swiftlynetworking")
        }
    }

    // MARK: Methods

    /// This methods sends the request to server. If it failes due to InvalidToken error, It tries to refresh the token and retry the request
    public func request<ResponseType: Decodable>(request: RequestProtocol, ResponseType: ResponseType.Type, TokenType: TokenType.Type) async throws -> ResponseType {
        let label = "\(requestCount) - \(request.rPath)"
        requestCount = requestCount + 1
        
        print("RECEIVED: ", label)
        let task = queue.sync {
            print("QUEUE #1: ", request.rPath)
            return Task {
                print("TASK #2: ", request.rPath)
                do {
                    try await Thread.sleep(forTimeInterval: 3)
                    let response = try await makeRequest(request: request, ResponseType: ResponseType)
                    print("RECEIVED #3: ", request.rPath)
                    return response
                } catch ApiError.InvalidToken {
                    try await refreshToken(TokenType: TokenType)
                    return try await makeRequest(request: request, ResponseType: ResponseType)
                } catch {
                    throw error
                }
            }
        }
        let response = try await task.value
        print("FINISHED: ", label)
        return response
//
//        let result = try await wow.value
//
//        return try await withCheckedThrowingContinuation { continuation in
//            queue.sync {
//                Task {
//                    do {
//                        let response = try await makeRequest(request: request, ResponseType: ResponseType)
//                        continuation.resume(returning: response)
//                    } catch ApiError.InvalidToken {
//                        do {
//                            try await refreshToken(TokenType: TokenType)
//                            let response = try await makeRequest(request: request, ResponseType: ResponseType)
//                            continuation.resume(returning: response)
//                        } catch {
//                            continuation.resume(throwing: error)
//                        }
//                    } catch {
//                        continuation.resume(throwing: error)
//                    }
//                }
//            }
//        }
    }

    private func makeRequest<ResponseType: Decodable>(request: RequestProtocol, ResponseType: ResponseType.Type) async throws -> ResponseType {
        // Get the URLRequest
        let urlRequest = try request.getURLRequest(withServerConfig: serverConfig, withAuthToken: delegate?.getAuthToken())

        // Make the request, get the data
        let data = try await networkLoader.sendRequest(urlRequest: urlRequest)

        // Decode the data
        return try responseParser.parse(data: data, request: request, Type: ResponseType)
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
