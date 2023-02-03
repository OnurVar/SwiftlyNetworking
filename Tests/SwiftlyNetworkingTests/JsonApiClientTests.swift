//
//  JsonApiClientTests.swift
//
//
//  Created by Onur Var on 1.02.2023.
//

@testable import SwiftlyNetworking
import XCTest

class JsonApiClientTests: XCTestCase {
    let validToken = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxZGExZjg4NS1jNGMwLTRjZGYtOTc3OS1jNThhZmViMWU1ZjkiLCJhdWQiOiJjIiwiaWF0IjoxNjc1MjMwNTg2MDMwLCJleHAiOjE2NzUyMzIzODYwMzAsInZlcmlmaWVkIjp0cnVlfQ.UXBtexGKWNS14VI0kqUt8cGr260K7D7k3j5RDnCLZs4"
    let invalidToken = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJiYWIwODc5Yy1mZDNmLTQzY2QtODU2Ny1jNDcxZjIwODA0NmIiLCJhdWQiOiJjIiwiaWF0IjoxNjQ2MTUyODEzNDUxLCJleHAiOjE2NDYxNTQ2MTM0NTEsInZlcmlmaWVkIjp0cnVlfQ.aXBFZaxkeTZpZGiZdJDS7EU8wgmwYap7S7bDO7OxWq4"
    let refreshToken = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxZGExZjg4NS1jNGMwLTRjZGYtOTc3OS1jNThhZmViMWU1ZjkiLCJhdWQiOiJjIiwiaWF0IjoxNjc1MjMwNTg2MDMwLCJleHAiOjE3MDY3NjY1ODYwMzB9.fi6umOkzXRvo-6qEcHVj7OW_0eOVOFYVvjKHxuICkss"

    var authToken: String?
    var refreshTokenRequest: RequestProtocol?
    var invalidTokenResponse = false

    var serverConfig: ServerConfigMock!
    var requestConfig: RequestConfigMock!

    var responseParser: ResponseParser!
    var networkLoader: NetworkLoader!
    var apiClient: ApiClient<JWTApiEntity>!

    override func setUp() {
        authToken = nil
        refreshTokenRequest = nil
        invalidTokenResponse = false

        serverConfig = ServerConfigMock()
        requestConfig = RequestConfigMock()

        responseParser = ResponseParser()
        responseParser.delegate = self

        networkLoader = NetworkLoader()
        networkLoader.delegate = self

        apiClient = ApiClient(responseParser: responseParser, networkLoader: networkLoader, serverConfig: serverConfig)
        apiClient.delegate = self
    }

    func test_non_exist_endpoint() async throws {
        // Execute

        do {
            let request = NonExistRequest()
            let response = try await apiClient.request(request: request, ResponseType: [WalkthroughApiEntity].self, TokenType: JWTApiEntity.self)
            XCTAssertEqual(response.count, 0)
        } catch {
            XCTAssertEqual(error.localizedDescription, ApiError.ServerError(statusCode: 404, message: "Cannot GET /no_endpoint").localizedDescription)
        }
    }

    func test_unauthorized_endpoint_no_auth_token() async throws {
        // Execute
        let request = GetWalkthroughListUseCase()
        let response = try await apiClient.request(request: request, ResponseType: [WalkthroughApiEntity].self, TokenType: JWTApiEntity.self)
        XCTAssertNotEqual(response.count, 0)
    }

    func test_authorized_endpoint_with_token() async throws {
        // Setup
        authToken = validToken

        // Execute
        let request = GetTagListRequest()
        let response = try await apiClient.request(request: request, ResponseType: [TagApiEntity].self, TokenType: JWTApiEntity.self)
        XCTAssertNotEqual(response.count, 0)
    }

    func test_authorized_endpoint_with_no_token() async throws {
        // Execute
        do {
            let request = GetTagListRequest()
            let response = try await apiClient.request(request: request, ResponseType: [TagApiEntity].self, TokenType: JWTApiEntity.self)
            XCTAssertEqual(response.count, 0)
        } catch {
            XCTAssertEqual(error.localizedDescription, ApiError.ServerError(statusCode: 401, message: "Unauthorized").localizedDescription)
        }
    }

    func test_authorized_endpoint_invalid_token_no_refresh_request() async throws {
        // Setup
        authToken = invalidToken

        // Execute
        do {
            let request = GetTagListRequest()
            let response = try await apiClient.request(request: request, ResponseType: [TagApiEntity].self, TokenType: JWTApiEntity.self)
            XCTAssertEqual(response.count, 0)
        } catch {
            XCTAssertEqual(error.localizedDescription, ApiError.ServerError(statusCode: 401, message: "Unauthorized").localizedDescription)
        }
    }

    func test_authorized_endpoint_invalid_token_with_invalid_token_response_no_refresh_request() async throws {
        // Setup
        authToken = invalidToken
        invalidTokenResponse = true

        // Execute
        do {
            let request = GetTagListRequest()
            let response = try await apiClient.request(request: request, ResponseType: [TagApiEntity].self, TokenType: JWTApiEntity.self)
            XCTAssertEqual(response.count, 0)
        } catch {
            XCTAssertEqual(error.localizedDescription, ApiError.InvalidToken.localizedDescription)
        }
    }

    func test_authorized_endpoint_invalid_token_with_invalid_token_response_with_refresh_request() async throws {
        // Setup
        authToken = invalidToken
        invalidTokenResponse = true
        refreshTokenRequest = PostCustomerRefresh(body: .init(refresh_token: refreshToken))

        // Execute
        let request = GetTagListRequest()
        let response = try await apiClient.request(request: request, ResponseType: [TagApiEntity].self, TokenType: JWTApiEntity.self)
        XCTAssertNotEqual(response.count, 0)
    }
}

extension JsonApiClientTests: NetworkLoaderDelegateProtocol {
    func getLogger(urlRequest: URLRequest) -> NetworkLoggerProtocol? {
        let logger = NetworkLogger(withURLRequest: urlRequest, withRequestConfig: requestConfig)
        return logger
    }

    func checkInvalidTokenResponse(errorMessage: String) -> Bool {
        print("checkInvalidTokenResponse", errorMessage)
        return invalidTokenResponse
    }

    func parseErrorMessage(data: Data) -> String? {
        let message = try? JSONDecoder().decode(ErrorApiEntity.self, from: data)
        return message?.message
    }
}

extension JsonApiClientTests: ResponseParserDelegateProtocol {
    func getJsonDecoder(request: SwiftlyNetworking.RequestProtocol) -> JSONDecoder? {
        return JSONDecoder()
    }
}

extension JsonApiClientTests: ApiClientDelegateProtocol {
    func onTokenChange(decodableToken: Decodable) {
        guard let token = decodableToken as? JWTApiEntity else {
            return
        }
        print("onTokenChange", token)
        authToken = token.token
    }

    func getRefreshTokenRequest() -> SwiftlyNetworking.RequestProtocol? {
        return refreshTokenRequest
    }

    func getAuthToken() -> String? {
        return authToken
    }

    func onTokenRemove() {
        print("onTokenRemove")
    }
}
