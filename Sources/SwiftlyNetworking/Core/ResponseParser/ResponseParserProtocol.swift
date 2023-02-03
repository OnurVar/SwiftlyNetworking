//
//  ResponseParserProtocol.swift
//
//
//  Created by Onur Var on 3.02.2023.
//

import Foundation

protocol ResponseParserProtocol {
    func parse<T: Decodable>(data: Data, request: RequestProtocol, Type: T.Type) throws -> T
}
