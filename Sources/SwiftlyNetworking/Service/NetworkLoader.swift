//
//  NetworkLoader.swift
//
//
//  Created by Onur Var on 1.02.2023.
//

import Foundation

struct NetworkLoader: NetworkLoaderProtocol {
    // MARK: Variables

    var requestConfig: RequestConfigProtocol
    var serverConfig: ServerConfigProtocol
    var parserDelegate: ApiClientParserDelegate?
    var logicDelegate: ApiClientLogicDelegateProtocol?

    // MARK: Methods

    func sendRequest<T: Decodable>(request: RequestProtocol, authToken: String?, Type: T.Type) async throws -> T {
        // Get the URLRequest
        let urlRequest = try request.getRequest(config: serverConfig, authToken: authToken)

        // Execute
        let (data, response) = try await execute(urlRequest: urlRequest)

        // Check if StatusCode exist
        guard let statusCode = (response as? HTTPURLResponse)?.statusCode else {
            throw ApiError.NoStatusCode
        }

        // Check if StatusCode is between 200 ... 299
        guard let statusCode = (response as? HTTPURLResponse)?.statusCode, (200 ... 299).contains(statusCode) else {
            // Something failed, Check the data
            guard let errorMessage = parserDelegate?.parseErrorMessage(data: data) else {
                throw ApiError.BadResponse(statusCode: statusCode)
            }

            if let isInvalidToken = logicDelegate?.checkInvalidTokenResponse(errorMessage: errorMessage), isInvalidToken {
                throw ApiError.InvalidToken
            }

            throw ApiError.ServerError(statusCode: statusCode, message: errorMessage)
        }

        let parsedData = try parse(data: data, request: request, Type: Type)
        return parsedData
    }

    func execute(urlRequest: URLRequest) async throws -> (Data, URLResponse) {
        let logger = NetworkLogger(withURLRequest: urlRequest, withConfig: requestConfig)
        do {
            let (data, response) = try await URLSession.shared.data(for: urlRequest)
            logger.log(data: data, response: response)
            return (data, response)
        } catch {
            logger.log(error: error)
            throw ApiError.NetworkError(message: error.localizedDescription)
        }
    }

    func parse<T: Decodable>(data: Data, request: RequestProtocol, Type: T.Type) throws -> T {
        guard let decoder = parserDelegate?.getJsonDecoder(request: request) else {
            throw ApiError.NoJsonDecoder
        }
        guard data.count > 0 else {
            guard let emptyResponse = EmptyResponse() as? T else {
                throw ApiError.UnknownNetworkError
            }
            return emptyResponse
        }
        do {
            let response = try decoder.decode(Type, from: data)
            return response
        } catch {
            throw ApiError.BadDecoding(message: error.localizedDescription)
        }
    }
}
