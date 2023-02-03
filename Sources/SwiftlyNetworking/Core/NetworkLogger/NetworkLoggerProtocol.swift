//
//  NetworkLoggerProtocol.swift
//
//
//  Created by Onur Var on 3.02.2023.
//

import Foundation

public protocol NetworkLoggerProtocol {
    func log(data: Data, response: URLResponse)
    func log(error: Error)
}
