//
//  ServerConfigMock.swift
//
//
//  Created by Onur Var on 1.02.2023.
//

@testable import SwiftlyNetworking

struct ServerConfigMock: ServerConfigProtocol {
    let scheme = "https"
    let host = "reqres.in/api"
}
