//
//  RequestProtocol.swift
//
//
//  Created by Onur Var on 31.01.2023.
//

import Foundation

protocol RequestProtocol {
    var rPath: String { get }
    var rHttpMethod: String { get }
    var rQueryParameter: Encodable? { get }
    var rBody: Data? { get }
    var rHeaders: [String: String]? { get }
    var rRefreshTokenOnFailEnabled: Bool { get }
}
