//
//  JsonApiClientTests.swift
//
//
//  Created by Onur Var on 1.02.2023.
//

@testable import SwiftlyNetworking
import XCTest

class JsonApiClientTests: XCTestCase {
    let validToken = ""
    let invalidToken = ""
    let refreshToken = ""

    let session: URLSession = .shared
    var authToken: String?
    var refreshTokenRequest: RequestProtocol?
    var invalidTokenResponse = false

    var serverConfig: ServerConfigMock!
    var requestConfig: RequestConfigMock!

    var responseParser: ResponseParser!
    var networkLoader: NetworkLoader!
    var apiClient: ApiClient<JWTApiEntity>!

    var responses: [MockRequestResultType] = []

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

    func _test_non_exist_endpoint() async throws {
        // Execute
        do {
            let request = NonExistRequest()
            let response = try await apiClient.request(request: request, ResponseType: [WalkthroughApiEntity].self, TokenType: JWTApiEntity.self)
            XCTAssertEqual(response.count, 0)
        } catch {
            XCTAssertEqual(error.localizedDescription, ApiError.ServerError(statusCode: 404, message: "Cannot POST /no_endpoint").localizedDescription)
        }
    }

    func _test_unauthorized_endpoint_no_auth_token() async throws {
        // Execute
        let request = GetWalkthroughListRequest()
        let response = try await apiClient.request(request: request, ResponseType: [WalkthroughApiEntity].self, TokenType: JWTApiEntity.self)
        XCTAssertNotEqual(response.count, 0)
    }

    func _test_authorized_endpoint_with_token() async throws {
        // Setup
        authToken = validToken

        // Execute
        do {
            let request = GetTagListRequest()
            let response = try await apiClient.request(request: request, ResponseType: [TagApiEntity].self, TokenType: JWTApiEntity.self)
            XCTAssertNotEqual(response.count, 0)
        } catch {
            XCTAssertEqual(error.localizedDescription, ApiError.ServerError(statusCode: 401, message: "Unauthorized").localizedDescription)
        }
    }

    func _test_authorized_endpoint_with_no_token() async throws {
        // Execute
        do {
            let request = GetTagListRequest()
            let response = try await apiClient.request(request: request, ResponseType: [TagApiEntity].self, TokenType: JWTApiEntity.self)
            XCTAssertEqual(response.count, 0)
        } catch {
            XCTAssertEqual(error.localizedDescription, ApiError.ServerError(statusCode: 401, message: "Unauthorized").localizedDescription)
        }
    }

    func _test_authorized_endpoint_invalid_token_no_refresh_request() async throws {
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

    func _test_authorized_endpoint_invalid_token_with_invalid_token_response_no_refresh_request() async throws {
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

    func _test_authorized_endpoint_invalid_token_with_invalid_token_response_with_refresh_request() async throws {
        // Setup
        authToken = invalidToken
        invalidTokenResponse = true
        refreshTokenRequest = PostCustomerRefresh(body: .init(refresh_token: refreshToken))

        // Execute
        let request = GetTagListRequest()
        let response = try await apiClient.request(request: request, ResponseType: [TagApiEntity].self, TokenType: JWTApiEntity.self)
        XCTAssertNotEqual(response.count, 0)
    }

    func test_apiClient_requests_are_serial() async throws {
        // Setup
        authToken = validToken

        // Execute
        let task1 = Task {
            do {
                let response = try await self.apiClient.request(request: GetTagListRequest(), ResponseType: [TagApiEntity].self, TokenType: JWTApiEntity.self)
                self.responses.append(.TagList)
                XCTAssertNotNil(response, "Response #0 should not be nil")
            } catch {
                XCTFail("Request #0 failed with error: \(error)")
            }
        }

        let task2 = Task {
            do {
                let response = try await self.apiClient.request(request: GetTagListRequest(), ResponseType: [TagApiEntity].self, TokenType: JWTApiEntity.self)
                self.responses.append(.TagList)
                XCTAssertNotNil(response, "Response #1 should not be nil")
            } catch {
                XCTFail("Request #1 failed with error: \(error)")
            }
        }

        let task3 = Task {
            do {
                let response = try await self.apiClient.request(request: GetWalkthroughListRequest(), ResponseType: [WalkthroughApiEntity].self, TokenType: JWTApiEntity.self)
                self.responses.append(.WalkthroughList)
                XCTAssertNotNil(response, "Response #2 should not be nil")
            } catch {
                XCTFail("Request #2 failed with error: \(error)")
            }
        }

        let task4 = Task {
            do {
                let response = try await self.apiClient.request(request: GetWalkthroughListRequest(), ResponseType: [WalkthroughApiEntity].self, TokenType: JWTApiEntity.self)
                self.responses.append(.WalkthroughList)
                XCTAssertNotNil(response, "Response #3 should not be nil")
            } catch {
                XCTFail("Request #3 failed with error: \(error)")
            }
        }

        // Wait for both tasks to finish
        try await task1.value
        try await task2.value
        try await task3.value
        try await task4.value

        // Verify
        XCTAssertEqual(responses.count, 8, "Responses count should be 8")
        XCTAssertEqual(responses[0], .TagList, "Response #0 should be TagList")
        XCTAssertEqual(responses[1], .TagList, "Response #1 should be TagList")
        XCTAssertEqual(responses[2], .WalkthroughList, "Response #2 should be WalkthroughList")
        XCTAssertEqual(responses[3], .WalkthroughList, "Response #3 should be WalkthroughList")
        // XCTAssertEqual(responses[4], .TagList, "Response #4 should be TagList")
        // XCTAssertEqual(responses[5], .WalkthroughList, "Response #5 should be WalkthroughList")
        // XCTAssertEqual(responses[6], .TagList, "Response #6 should be TagList")
        // XCTAssertEqual(responses[7], .TagList, "Response #7 should be TagList")
    }
}

extension JsonApiClientTests: NetworkLoaderDelegateProtocol {
    func getExecutor(urlRequest: URLRequest) -> any URLRequestExecutorProtocol {
        let logger = NetworkLogger(withURLRequest: urlRequest, withRequestConfig: requestConfig)
        return URLRequestExecutor(withUrlRequest: urlRequest, withSession: session, withNetworkLogger: logger)
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
