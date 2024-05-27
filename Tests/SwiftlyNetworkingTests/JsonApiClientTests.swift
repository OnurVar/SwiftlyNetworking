//
//  JsonApiClientTests.swift
//
//
//  Created by Onur Var on 1.02.2023.
//

@testable import SwiftlyNetworking
import XCTest

class JsonApiClientTests: XCTestCase {
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

        let queue: DispatchQueue = .init(label: "com.onurvar.swiftlynetworking", qos: .background)

        apiClient = ApiClient(responseParser: responseParser, networkLoader: networkLoader, serverConfig: serverConfig, queue: queue)
        apiClient.delegate = self
    }

    func _test_non_exist_endpoint() async throws {
        // Execute
        do {
            let request = NonExistRequest()
            let response = try await apiClient.request(request: request, ResponseType: [WalkthroughEntity].self, TokenType: JWTApiEntity.self)
            XCTAssertEqual(response.count, 0)
        } catch {
            XCTAssertEqual(error.localizedDescription, ApiError.ServerError(statusCode: 404, message: "Cannot POST /no_endpoint").localizedDescription)
        }
    }

    func _test_unauthorized_endpoint_no_auth_token() async throws {
        // Execute
        let request = GetWalkthroughListRequest()
        let response = try await apiClient.request(request: request, ResponseType: [WalkthroughEntity].self, TokenType: JWTApiEntity.self)
        XCTAssertNotEqual(response.count, 0)
    }

    func _test_authorized_endpoint_with_token() async throws {
        // Setup
        authToken = ClientTokenMock.shared.validToken

        // Execute
        do {
            let request = GetTagListRequest()
            let response = try await apiClient.request(request: request, ResponseType: [TagEntity].self, TokenType: JWTApiEntity.self)
            XCTAssertNotEqual(response.count, 0)
        } catch {
            XCTAssertEqual(error.localizedDescription, ApiError.ServerError(statusCode: 401, message: "Unauthorized").localizedDescription)
        }
    }

    func _test_authorized_endpoint_with_no_token() async throws {
        // Execute
        do {
            let request = GetTagListRequest()
            let response = try await apiClient.request(request: request, ResponseType: [TagEntity].self, TokenType: JWTApiEntity.self)
            XCTAssertEqual(response.count, 0)
        } catch {
            XCTAssertEqual(error.localizedDescription, ApiError.ServerError(statusCode: 401, message: "Unauthorized").localizedDescription)
        }
    }

    func _test_authorized_endpoint_invalid_token_no_refresh_request() async throws {
        // Setup
        authToken = ClientTokenMock.shared.invalidToken

        // Execute
        do {
            let request = GetTagListRequest()
            let response = try await apiClient.request(request: request, ResponseType: [TagEntity].self, TokenType: JWTApiEntity.self)
            XCTAssertEqual(response.count, 0)
        } catch {
            XCTAssertEqual(error.localizedDescription, ApiError.ServerError(statusCode: 401, message: "Unauthorized").localizedDescription)
        }
    }

    func _test_authorized_endpoint_invalid_token_with_invalid_token_response_no_refresh_request() async throws {
        // Setup
        authToken = ClientTokenMock.shared.invalidToken
        invalidTokenResponse = true

        // Execute
        do {
            let request = GetTagListRequest()
            let response = try await apiClient.request(request: request, ResponseType: [TagEntity].self, TokenType: JWTApiEntity.self)
            XCTAssertEqual(response.count, 0)
        } catch {
            XCTAssertEqual(error.localizedDescription, ApiError.InvalidToken.localizedDescription)
        }
    }

    func _test_authorized_endpoint_invalid_token_with_invalid_token_response_with_refresh_request() async throws {
        // Setup
        authToken = ClientTokenMock.shared.invalidToken
        invalidTokenResponse = true
        refreshTokenRequest = PostCustomerRefresh(body: .init(refresh_token: ClientTokenMock.shared.refreshToken))

        // Execute
        let request = GetTagListRequest()
        let response = try await apiClient.request(request: request, ResponseType: [TagEntity].self, TokenType: JWTApiEntity.self)
        XCTAssertNotEqual(response.count, 0)
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
