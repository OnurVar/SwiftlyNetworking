//
//  ResponseParserDelegateProtocol.swift
//
//
//  Created by Onur Var on 3.02.2023.
//

import Foundation

protocol ResponseParserDelegateProtocol {
    func getJsonDecoder(request: RequestProtocol) -> JSONDecoder?
}
