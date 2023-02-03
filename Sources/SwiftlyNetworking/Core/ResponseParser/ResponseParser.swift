//
//  ResponseParser.swift
//
//
//  Created by Onur Var on 3.02.2023.
//

import Foundation

public class ResponseParser {
    public var delegate: ResponseParserDelegateProtocol?
}

extension ResponseParser: ResponseParserProtocol {
    public func parse<T: Decodable>(data: Data, request: RequestProtocol, Type: T.Type) throws -> T {
        // Get the JSONDecoder for a request
        let decoder = delegate?.getJsonDecoder(request: request) ?? JSONDecoder()

        // Check if data exist
        guard data.count > 0 else {
            // Check if the parser expects to return 'EmptyResponse'
            guard let emptyResponse = EmptyResponse() as? T else {
                throw ApiError.UnknownNetworkError
            }
            return emptyResponse
        }

        // Decode the data
        do {
            let response = try decoder.decode(Type, from: data)
            return response
        } catch {
            throw ApiError.BadDecoding(message: error.localizedDescription)
        }
    }
}
