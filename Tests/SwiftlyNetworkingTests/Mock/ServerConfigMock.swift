//
//  ServerConfigMock.swift
//
//
//  Created by Onur Var on 1.02.2023.
//

@testable import SwiftlyNetworking

struct ServerConfigMock: ServerConfigProtocol {
    let scheme: String = "https"
    let host: String = "reqres.in/api"
    let port: Int? = nil
}
