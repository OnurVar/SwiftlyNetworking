//
//  NetworkClientTest.swift
//
//
//  Created by Onur Var on 1.02.2023.
//

@testable import SwiftlyNetworking
import XCTest

class NetworkServiceTests: XCTestCase {
    let serverConfig = ServerConfigMock()
//    let networkClient =

    func testCase1() async throws {
        print("testCase1")
        var networkClient = NetworkClient(serverConfig: serverConfig)
        networkClient.logicDelegate = self
        networkClient.parserDelegate = self

        let apiClient = ApiClient<JWT>(networkClient: networkClient)
        apiClient.tokenDelegate = self

        let request = EndpointMock.ListWalkthrough
        let response = try await apiClient.request(request: request, ResponseType: [WalkthroughApiEntity].self, TokenType: JWT.self)
        print("response", response)
    }
}

extension NetworkServiceTests: ApiClientLogicDelegateProtocol {
    func checkInvalidTokenResponse(errorMessage: String) -> Bool {
        print("errorMessage")
        return false
    }
}

extension NetworkServiceTests: ApiClientParserDelegate {
    func parseErrorMessage(data: Data) -> String? {
        return nil
    }

    func getJsonDecoder(request: SwiftlyNetworking.RequestProtocol) -> JSONDecoder {
        return JSONDecoder()
    }
}

extension NetworkServiceTests: ApiClientTokenDelegateProtocol {
    func getRefreshTokenRequest() -> SwiftlyNetworking.RequestProtocol {
        return EndpointMock.ListUser
    }

    func getRefreshToken() -> String? {
        return nil
    }

    func getAuthToken() -> String? {
        return nil
    }

    func onTokenChange(token: Decodable) {
        print("onTokenChange", token)
    }

    func onTokenRemove() {
        print("wow")
    }
}

struct JWT: Decodable {}

struct WalkthroughApiEntity: Decodable {
    var id: String
}
