//
//  ApiClientProtocol.swift
//
//
//  Created by Onur Var on 3.02.2023.
//

protocol ApiClientProtocol {
    associatedtype TokenType: Decodable
    func request<ResponseType: Decodable>(request: RequestProtocol, ResponseType: ResponseType.Type, TokenType: TokenType.Type) async throws -> ResponseType
}
