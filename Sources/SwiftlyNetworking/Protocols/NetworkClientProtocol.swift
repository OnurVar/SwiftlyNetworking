//
//  NetworkClientProtocol.swift
//
//
//  Created by Onur Var on 1.02.2023.
//

protocol NetworkClientProtocol {

    // MARK: Methods

    func sendRequest<T: Decodable>(request: RequestProtocol, authToken: String?, Type: T.Type) async throws -> T
}
