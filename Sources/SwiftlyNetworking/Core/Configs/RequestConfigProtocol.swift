//
//  RequestConfigProtocol.swift
//
//
//  Created by Onur Var on 1.02.2023.
//

protocol RequestConfigProtocol {
    var logRequest: Bool { get }
    var logRequestHeader: Bool { get }
    var logRequestBody: Bool { get }
    var logResponseHeader: Bool { get }
    var logResponseBody: Bool { get }
}
