//
//  NetworkLoaderProtocol.swift
//
//
//  Created by Onur Var on 1.02.2023.
//

protocol NetworkLoaderProtocol {

    // MARK: Methods

    func sendRequest<T: Decodable>(request: RequestProtocol, authToken: String?, Type: T.Type) async throws -> T
}
