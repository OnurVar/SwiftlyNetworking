//
//  NetworkLoaderProtocol.swift
//
//
//  Created by Onur Var on 1.02.2023.
//

import Foundation

public protocol NetworkLoaderProtocol {
    func sendRequest(urlRequest: URLRequest) async throws -> Data
}
