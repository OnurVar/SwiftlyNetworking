//
//  ServerConfigProtocol.swift
//
//
//  Created by Onur Var on 31.01.2023.
//

public protocol ServerConfigProtocol {
    var scheme: String { get }
    var host: String { get }
    var port: Int? { get }
}
