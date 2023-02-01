//
//  RequestProtocol.swift
//
//
//  Created by Onur Var on 31.01.2023.
//

public protocol RequestProtocol {
    // MARK: Variables

    var path: String { get }
    var httpMethod: String { get }
    var body: Encodable? { get }
    var queryParameter: Encodable? { get }
}
