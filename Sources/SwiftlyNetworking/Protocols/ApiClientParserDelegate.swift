//
//  ApiClientParserDelegate.swift
//
//
//  Created by Onur Var on 1.02.2023.
//

import Foundation

protocol ApiClientParserDelegate {
    func parseErrorMessage(data: Data) -> String?
    func getJsonDecoder(request: RequestProtocol) -> JSONDecoder
}
