//
//  ApiClientLogicDelegateProtocol.swift
//
//
//  Created by Onur Var on 1.02.2023.
//

protocol ApiClientLogicDelegateProtocol {
    func checkInvalidTokenResponse(errorMessage: String) -> Bool
}
