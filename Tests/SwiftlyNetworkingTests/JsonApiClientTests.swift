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
    var networkLoader: NetworkLoader!
    var jsonApiClient: JsonApiClient<JWTApiEntity>!

    override func setUp() {
        authToken = nil
        refreshTokenRequest = nil
        invalidTokenResponse = false

        serverConfig = ServerConfigMock()
        requestConfig = RequestConfigMock()

        networkLoader = NetworkLoader(requestConfig: requestConfig, serverConfig: serverConfig)
        networkLoader.logicDelegate = self
        networkLoader.parserDelegate = self

        jsonApiClient = JsonApiClient(networkLoader: networkLoader)
        jsonApiClient.tokenDelegate = self
    }

    func test_non_exist_endpoint() async throws {
        // Execute
        let request = EndpointMock.NoEndpoint
        do {
            let response = try await jsonApiClient.request(request: request, ResponseType: [WalkthroughApiEntity].self, TokenType: JWTApiEntity.self)
            XCTAssertEqual(response.count, 0)
        } catch {
            XCTAssertEqual(error.localizedDescription, ApiError.ServerError(statusCode: 404, message: "Cannot GET /no_endpoint").localizedDescription)
        }
    }

    func test_unauthorized_endpoint_no_auth_token() async throws {
        // Execute
        let request = EndpointMock.WalkthroughsList
        let response = try await jsonApiClient.request(request: request, ResponseType: [WalkthroughApiEntity].self, TokenType: JWTApiEntity.self)
        XCTAssertNotEqual(response.count, 0)
    }

    func test_authorized_endpoint_with_token() async throws {
        // Setup
        authToken = validToken

        // Execute
        let request = EndpointMock.TagsList
        let response = try await jsonApiClient.request(request: request, ResponseType: [TagApiEntity].self, TokenType: JWTApiEntity.self)
        XCTAssertNotEqual(response.count, 0)
    }

    func test_authorized_endpoint_with_no_token() async throws {
        // Execute
        let request = EndpointMock.TagsList
        do {
            let response = try await jsonApiClient.request(request: request, ResponseType: [TagApiEntity].self, TokenType: JWTApiEntity.self)
            XCTAssertEqual(response.count, 0)
        } catch {
            XCTAssertEqual(error.localizedDescription, ApiError.ServerError(statusCode: 401, message: "Unauthorized").localizedDescription)
        }
    }

    func test_authorized_endpoint_invalid_token_no_refresh_request() async throws {
        // Setup
        authToken = invalidToken

        // Execute
        let request = EndpointMock.TagsList
        do {
            let response = try await jsonApiClient.request(request: request, ResponseType: [TagApiEntity].self, TokenType: JWTApiEntity.self)
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
        let request = EndpointMock.TagsList
        do {
            let response = try await jsonApiClient.request(request: request, ResponseType: [TagApiEntity].self, TokenType: JWTApiEntity.self)
            XCTAssertEqual(response.count, 0)
        } catch {
            XCTAssertEqual(error.localizedDescription, ApiError.InvalidToken.localizedDescription)
        }
    }

    func test_authorized_endpoint_invalid_token_with_invalid_token_response_with_refresh_request() async throws {
        // Setup
        authToken = invalidToken
        invalidTokenResponse = true
        refreshTokenRequest = EndpointMock.CustomerRefresh(body: .init(refresh_token: refreshToken))

        // Execute
        let request = EndpointMock.TagsList
        let response = try await jsonApiClient.request(request: request, ResponseType: [TagApiEntity].self, TokenType: JWTApiEntity.self)
        XCTAssertNotEqual(response.count, 0)
    }
}

extension JsonApiClientTests: ApiClientLogicDelegateProtocol {
    func checkInvalidTokenResponse(errorMessage: String) -> Bool {
        print("checkInvalidTokenResponse", errorMessage)
        return invalidTokenResponse
    }
}

extension JsonApiClientTests: ApiClientParserDelegate {
    func parseErrorMessage(data: Data) -> String? {
        let message = try? JSONDecoder().decode(ErrorApiEntity.self, from: data)
        return message?.message
    }

    func getJsonDecoder(request: SwiftlyNetworking.RequestProtocol) -> JSONDecoder {
        return JSONDecoder()
    }
}

extension JsonApiClientTests: ApiClientTokenDelegateProtocol {
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
