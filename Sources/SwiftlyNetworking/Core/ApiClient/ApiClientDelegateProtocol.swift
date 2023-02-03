//
//  ApiClientDelegateProtocol.swift
//
//
//  Created by Onur Var on 1.02.2023.
//

public protocol ApiClientDelegateProtocol {
    func getRefreshTokenRequest() -> RequestProtocol?
    func getAuthToken() -> String?
    func onTokenChange(decodableToken: Decodable)
    func onTokenRemove()
}
