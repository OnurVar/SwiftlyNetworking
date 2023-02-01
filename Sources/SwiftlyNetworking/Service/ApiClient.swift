//
//  ApiClient.swift
//
//
//  Created by Onur Var on 1.02.2023.
//

class ApiClient<TokenType: Decodable> {
    // MARK: Variables

    var tokenDelegate: ApiClientTokenDelegateProtocol?
    var networkClient: NetworkClientProtocol

    // MARK: Life Cycle

    init(networkClient: NetworkClientProtocol) {
        self.networkClient = networkClient
    }

    // MARK: Methods

    /// This methods sends the request to server. If it failes due to InvalidToken error, It tries to refresh the token and retry the request
    func request<ResponseType: Decodable>(request: RequestProtocol, ResponseType: ResponseType.Type, TokenType: TokenType.Type) async throws -> ResponseType {
        do {
            return try await networkClient.sendRequest(request: request, authToken: tokenDelegate?.getAuthToken(), Type: ResponseType)
        } catch ApiError.InvalidToken {
            try await refreshToken(TokenType: TokenType)
            return try await networkClient.sendRequest(request: request, authToken: tokenDelegate?.getAuthToken(), Type: ResponseType)
        } catch {
            throw error
        }
    }

    func refreshToken(TokenType: TokenType.Type) async throws {
        guard let request = tokenDelegate?.getRefreshTokenRequest() else {
            return
        }
        let authToken = tokenDelegate?.getAuthToken()
        let token = try await networkClient.sendRequest(request: request, authToken: authToken, Type: TokenType)
        tokenDelegate?.onTokenChange(token: token)
    }
}
