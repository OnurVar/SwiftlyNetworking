//
//  SerialRequestTests.swift
//
//
//  Created by Onur Var on 26.05.2024.
//

@testable import SwiftlyNetworking
import XCTest

class SerialRequestTests: XCTestCase {
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

    func test_2_requests_are_serial() async {
        let serialQueue = DispatchQueue(label: "SERIAL")
        let group = DispatchGroup()

        group.enter()
        serialQueue.async(group: group) {
            Task {
                await self.getTagList(taskName: "#0")
                group.leave()
            }
        }

        serialQueue.async {
            group.enter()
            Task {
                await self.getSpaceList(taskName: "#1")
                group.leave()
            }
        }

        serialQueue.async {
            group.enter()
            Task {
                await self.getWalkthroughList(taskName: "#2")
                group.leave()
            }
        }

        serialQueue.async {
            group.enter()
            Task {
                await self.getTagList(taskName: "#3")
                group.leave()
            }
        }

        serialQueue.async {
            group.enter()
            Task {
                await self.getTagList(taskName: "#4")
                group.leave()
            }
        }

        serialQueue.async {
            group.enter()
            Task {
                await self.getWalkthroughList(taskName: "#5")
                group.leave()
            }
        }

        serialQueue.async {
            group.enter()
            Task {
                await self.getTagList(taskName: "#6")
                group.leave()
            }
        }

        serialQueue.async {
            group.enter()
            Task {
                await self.getSpaceList(taskName: "#7")
                group.leave()
            }
        }

        serialQueue.async {
            group.enter()
            Task {
                await self.getSpaceList(taskName: "#8")
                group.leave()
            }
        }

        group.notify(queue: serialQueue) {
            XCTAssertTrue(self.responses[0] == .TagList, "Response #0 should be TagList")
            XCTAssertTrue(self.responses[1] == .SpaceList, "Response #1 should be SpaceList")
            XCTAssertTrue(self.responses[2] == .WalkthroughList, "Response #2 should be WalkthroughList")

            XCTAssertTrue(self.responses[3] == .TagList, "Response #3 should be TagList")
            XCTAssertTrue(self.responses[4] == .TagList, "Response #4 should be TagList")
            XCTAssertTrue(self.responses[5] == .WalkthroughList, "Response #5 should be WalkthroughList")

            XCTAssertTrue(self.responses[6] == .TagList, "Response #6 should be TagList")
            XCTAssertTrue(self.responses[7] == .SpaceList, "Response #7 should be SpaceList")
            XCTAssertTrue(self.responses[8] == .SpaceList, "Response #8 should be SpaceList")
        }
        print("TEST FINISHED")
    }

    private func getTagList(taskName: String) async {
        print("\(taskName) STARTED")
        do {
            let response = try await apiClient.request(request: GetTagListRequest(), ResponseType: [TagEntity].self, TokenType: JWTApiEntity.self)
            responses.append(.TagList)
            XCTAssertNotNil(response, "Response \(taskName) should not be nil")
            print("\(taskName) FINISHED")
        } catch {
            XCTFail("Request \(taskName) failed with error: \(error)")
        }
    }

    private func getSpaceList(taskName: String) async {
        print("\(taskName) STARTED")
        do {
            let response = try await apiClient.request(request: GetSpaceListRequest(), ResponseType: [SpaceEntity].self, TokenType: JWTApiEntity.self)
            responses.append(.SpaceList)
            XCTAssertNotNil(response, "Response \(taskName) should not be nil")
            print("\(taskName) FINISHED")
        } catch {
            XCTFail("Request \(taskName) failed with error: \(error)")
        }
    }

    private func getWalkthroughList(taskName: String) async {
        print("\(taskName) STARTED")
        do {
            let response = try await apiClient.request(request: GetWalkthroughListRequest(), ResponseType: [WalkthroughEntity].self, TokenType: JWTApiEntity.self)
            responses.append(.WalkthroughList)
            XCTAssertNotNil(response, "Response \(taskName) should not be nil")
            print("\(taskName) FINISHED")
        } catch {
            XCTFail("Request \(taskName) failed with error: \(error)")
        }
    }
}

extension SerialRequestTests: NetworkLoaderDelegateProtocol {
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

extension SerialRequestTests: ResponseParserDelegateProtocol {
    func getJsonDecoder(request: SwiftlyNetworking.RequestProtocol) -> JSONDecoder? {
        return JSONDecoder()
    }
}

extension SerialRequestTests: ApiClientDelegateProtocol {
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
