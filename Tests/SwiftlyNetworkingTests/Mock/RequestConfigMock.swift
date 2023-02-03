//
//  RequestConfigMock.swift
//
//
//  Created by Onur Var on 1.02.2023.
//

@testable import SwiftlyNetworking

struct RequestConfigMock: RequestConfigProtocol {
    var logRequest = true
    var logRequestHeader = false
    var logRequestBody = false
    var logResponseHeader = false
    var logResponseBody = false
}
