//
//  RequestMock.swift
//
//
//  Created by Onur Var on 1.02.2023.
//

@testable import SwiftlyNetworking

enum EndpointMock {
    case ListUser
    case ListWalkthrough
}

extension EndpointMock: RequestProtocol {
    var path: String {
        switch self {
        case .ListUser:
            return "/users"
        case .ListWalkthrough:
            return "/walk_throughs/list"
        }
    }

    var httpMethod: String {
        return "GET"
    }

    var body: Encodable? {
        return nil
    }

    var queryParameter: Encodable? {
        return nil
    }
}
