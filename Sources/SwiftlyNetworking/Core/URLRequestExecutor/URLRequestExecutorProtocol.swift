//
//  URLRequestExecutorProtocol.swift
//
//
//  Created by Onur Var on 26.05.2024.
//

import Foundation

public protocol URLRequestExecutorProtocol {
    func execute() async throws -> (Data, URLResponse)
}
