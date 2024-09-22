//
//  ResponseParser.swift
//
//
//  Created by Onur Var on 3.02.2023.
//

import Foundation

public class ResponseParser {
    // MARK: Variables

    public var delegate: ResponseParserDelegateProtocol?

    // MARK: Life Cycle

    public init() {}
}

extension ResponseParser: ResponseParserProtocol {
    public func parse<T: Decodable>(data: Data, request: RequestProtocol, Type: T.Type) throws -> T? {
        // Get the JSONDecoder for a request
        let decoder = delegate?.getJsonDecoder(request: request) ?? JSONDecoder()

        // Make sure the data is not empty
        guard data.count > 0 else { return nil }

        // Decode the data
        do {
            let response = try decoder.decode(Type, from: data)
            return response
        } catch {
            throw ApiError.BadDecoding(message: error.localizedDescription)
        }
    }
}
