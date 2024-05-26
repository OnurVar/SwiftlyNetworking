//
//  NetworkLoaderDelegateProtocol.swift
//
//
//  Created by Onur Var on 3.02.2023.
//

import Foundation

public protocol NetworkLoaderDelegateProtocol {
    func parseErrorMessage(data: Data) -> String?
    func checkInvalidTokenResponse(errorMessage: String) -> Bool
    func getExecutor(urlRequest: URLRequest) -> URLRequestExecutorProtocol
}
