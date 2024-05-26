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

        apiClient = ApiClient(responseParser: responseParser, networkLoader: networkLoader, serverConfig: serverConfig)
        apiClient.delegate = self
    }

    func test_apiClient_requests_are_serial() async throws {
        // Setup
        authToken = ClientTokenMock.shared.validToken
        let semaphore = DispatchSemaphore(value: 1)

        // Execute
        let task0 = Task {
            let taskName = "#0"
            semaphore.wait()
            await self.getWalkthroughList(taskName: taskName)
            semaphore.signal()
        }

        let task1 = Task {
            let taskName = "#1"
            semaphore.wait()
            await self.getTagList(taskName: taskName)
            semaphore.signal()
        }

        let task2 = Task {
            let taskName = "#2"
            semaphore.wait()
            await self.getWalkthroughList(taskName: taskName)
            semaphore.signal()
        }

        let task3 = Task {
            let taskName = "#3"
            semaphore.wait()
            await self.getSpaceList(taskName: taskName)
            semaphore.signal()
        }

        let task4 = Task {
            let taskName = "#4"
            semaphore.wait()
            await self.getWalkthroughList(taskName: taskName)
            semaphore.signal()
        }

        let task5 = Task {
            let taskName = "#5"
            semaphore.wait()
            await self.getWalkthroughList(taskName: taskName)
            semaphore.signal()
        }

        let task6 = Task {
            let taskName = "#6"
            semaphore.wait()
            await self.getSpaceList(taskName: taskName)
            semaphore.signal()
        }

        let task7 = Task {
            let taskName = "#7"
            semaphore.wait()
            await self.getTagList(taskName: taskName)
            semaphore.signal()
        }

        let task8 = Task {
            let taskName = "#8"
            semaphore.wait()
            await self.getSpaceList(taskName: taskName)
            semaphore.signal()
        }

        let task9 = Task {
            let taskName = "#9"
            semaphore.wait()
            await self.getWalkthroughList(taskName: taskName)
            semaphore.signal()
        }

        let task10 = Task {
            let taskName = "#10"
            semaphore.wait()
            await self.getTagList(taskName: taskName)
            semaphore.signal()
        }

        let task11 = Task {
            let taskName = "#11"
            semaphore.wait()
            await self.getSpaceList(taskName: taskName)
            semaphore.signal()
        }

        let task12 = Task {
            let taskName = "#12"
            semaphore.wait()
            await self.getTagList(taskName: taskName)
            semaphore.signal()
        }

        let task13 = Task {
            let taskName = "#13"
            semaphore.wait()
            await self.getTagList(taskName: taskName)
            semaphore.signal()
        }

        let task14 = Task {
            let taskName = "#14"
            semaphore.wait()
            await self.getSpaceList(taskName: taskName)
            semaphore.signal()
        }

        let task15 = Task {
            let taskName = "#15"
            semaphore.wait()
            await self.getWalkthroughList(taskName: taskName)
            semaphore.signal()
        }

        let task16 = Task {
            let taskName = "#16"
            semaphore.wait()
            await self.getTagList(taskName: taskName)
            semaphore.signal()
        }

        let task17 = Task {
            let taskName = "#17"
            semaphore.wait()
            await self.getWalkthroughList(taskName: taskName)
            semaphore.signal()
        }

        await task0.value
        await task1.value
        await task2.value
        await task3.value
        await task4.value
        await task5.value
        await task6.value
        await task7.value
        await task8.value
        await task9.value
        await task10.value
        await task11.value
        await task12.value
        await task13.value
        await task14.value
        await task15.value
        await task16.value
        await task17.value

        // Verify
        XCTAssertTrue(responses.count == 18, "Responses count should be 18")
        XCTAssertTrue(responses[0] == .WalkthroughList, "Response #0 should be WalkthroughList")
        XCTAssertTrue(responses[1] == .TagList, "Response #1 should be TagList")
        XCTAssertTrue(responses[2] == .WalkthroughList, "Response #2 should be WalkthroughList")

        XCTAssertTrue(responses[3] == .SpaceList, "Response #3 should be SpaceList")
        XCTAssertTrue(responses[4] == .WalkthroughList, "Response #4 should be WalkthroughList")
        XCTAssertTrue(responses[5] == .WalkthroughList, "Response #5 should be WalkthroughList")

        XCTAssertTrue(responses[6] == .SpaceList, "Response #6 should be SpaceList")
        XCTAssertTrue(responses[7] == .TagList, "Response #7 should be TagList")
        XCTAssertTrue(responses[8] == .SpaceList, "Response #8 should be SpaceList")

        XCTAssertTrue(responses[9] == .WalkthroughList, "Response #9 should be WalkthroughList")
        XCTAssertTrue(responses[10] == .TagList, "Response #10 should be TagList")
        XCTAssertTrue(responses[11] == .SpaceList, "Response #11 should be SpaceList")

        XCTAssertTrue(responses[12] == .TagList, "Response #12 should be WalkthroughList")
        XCTAssertTrue(responses[13] == .TagList, "Response #13 should be TagList")
        XCTAssertTrue(responses[14] == .SpaceList, "Response #14 should be SpaceList")

        XCTAssertTrue(responses[15] == .WalkthroughList, "Response #15 should be WalkthroughList")
        XCTAssertTrue(responses[15] == .TagList, "Response #15 should be TagList")
        XCTAssertTrue(responses[15] == .WalkthroughList, "Response #16 should be WalkthroughList")
    }

    func _testCase1() async {
        let serialQueue = DispatchQueue(label: "SERIAL")
        serialQueue.async {
            Task {
                await self.getTagList(taskName: "0")
            }
        }
        serialQueue.async {
            Task {
                await self.getTagList(taskName: "1")
            }
        }
        serialQueue.async {
            Task {
                await self.getSpaceList(taskName: "2")
            }
        }
        serialQueue.async {
            Task {
                await self.getWalkthroughList(taskName: "3")
            }
        }
        serialQueue.async {
            Task {
                await self.getSpaceList(taskName: "4")
            }
        }
    }

    private func getTagList(taskName: String) async {
        print("\(taskName) STARTED")
        do {
            let response = try await apiClient.request(taskName: taskName, request: GetTagListRequest(), ResponseType: [TagEntity].self, TokenType: JWTApiEntity.self)
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
            let response = try await apiClient.request(taskName: taskName, request: GetSpaceListRequest(), ResponseType: [SpaceEntity].self, TokenType: JWTApiEntity.self)
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
            let response = try await apiClient.request(taskName: taskName, request: GetWalkthroughListRequest(), ResponseType: [WalkthroughEntity].self, TokenType: JWTApiEntity.self)
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
