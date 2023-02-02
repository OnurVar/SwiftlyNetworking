//
//  JsonApiClient.swift
//
//
//  Created by Onur Var on 1.02.2023.
//

class JsonApiClient<TokenType: Decodable> {
    // MARK: Variables

    var tokenDelegate: ApiClientTokenDelegateProtocol?
    var networkLoader: NetworkLoaderProtocol

    // MARK: Life Cycle

    init(networkLoader: NetworkLoaderProtocol) {
        self.networkLoader = networkLoader
    }

    // MARK: Methods

    /// This methods sends the request to server. If it failes due to InvalidToken error, It tries to refresh the token and retry the request
    func request<ResponseType: Decodable>(request: RequestProtocol, ResponseType: ResponseType.Type, TokenType: TokenType.Type) async throws -> ResponseType {
        do {
            return try await networkLoader.sendRequest(request: request, authToken: tokenDelegate?.getAuthToken(), Type: ResponseType)
        } catch ApiError.InvalidToken {
            try await refreshToken(TokenType: TokenType)
            return try await networkLoader.sendRequest(request: request, authToken: tokenDelegate?.getAuthToken(), Type: ResponseType)
        } catch {
            throw error
        }
    }

    func refreshToken(TokenType: TokenType.Type) async throws {
        guard let request = tokenDelegate?.getRefreshTokenRequest() else {
            return
        }
        let authToken = tokenDelegate?.getAuthToken()
        let decodableToken = try await networkLoader.sendRequest(request: request, authToken: authToken, Type: TokenType)
        tokenDelegate?.onTokenChange(decodableToken: decodableToken)
    }
}
