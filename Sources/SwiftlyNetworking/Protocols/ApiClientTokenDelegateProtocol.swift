//
//  ApiClientTokenDelegateProtocol.swift
//
//
//  Created by Onur Var on 1.02.2023.
//

protocol ApiClientTokenDelegateProtocol {
//    associatedtype JWT: Encodable
    func getRefreshTokenRequest() -> RequestProtocol
    func getRefreshToken() -> String?
    func getAuthToken() -> String?
    func onTokenChange(token: Decodable)
    func onTokenRemove()
}
