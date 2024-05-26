//
//  ApiClientProtocol.swift
//
//
//  Created by Onur Var on 3.02.2023.
//

public protocol ApiClientProtocol {
    associatedtype TokenType: Decodable
    func request<ResponseType: Decodable>(taskName: String, request: RequestProtocol, ResponseType: ResponseType.Type, TokenType: TokenType.Type) async throws -> ResponseType
}
