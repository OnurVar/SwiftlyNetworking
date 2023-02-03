//
//  ApiClient.swift
//
//
//  Created by Onur Var on 1.02.2023.
//

public class ApiClient<TokenType: Decodable>: ApiClientProtocol {
    // MARK: Variables

    public var delegate: ApiClientDelegateProtocol?
    private var responseParser: ResponseParserProtocol
    private var networkLoader: NetworkLoaderProtocol
    private var serverConfig: ServerConfigProtocol

    // MARK: Life Cycle

    public init(
        responseParser: ResponseParserProtocol,
        networkLoader: NetworkLoaderProtocol,
        serverConfig: ServerConfigProtocol
    ) {
        self.responseParser = responseParser
        self.networkLoader = networkLoader
        self.serverConfig = serverConfig
    }

    // MARK: Methods

    /// This methods sends the request to server. If it failes due to InvalidToken error, It tries to refresh the token and retry the request
    public func request<ResponseType: Decodable>(request: RequestProtocol, ResponseType: ResponseType.Type, TokenType: TokenType.Type) async throws -> ResponseType {
        do {
            return try await makeRequest(request: request, ResponseType: ResponseType)
        } catch ApiError.InvalidToken {
            try await refreshToken(TokenType: TokenType)
            return try await makeRequest(request: request, ResponseType: ResponseType)
        } catch {
            throw error
        }
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
