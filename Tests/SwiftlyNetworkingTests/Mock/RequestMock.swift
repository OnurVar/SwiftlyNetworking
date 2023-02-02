//
//  RequestMock.swift
//
//
//  Created by Onur Var on 1.02.2023.
//

@testable import SwiftlyNetworking

enum EndpointMock {
    case NoEndpoint
    case WalkthroughsList
    case TagsList
    case CustomerRefresh(body: CustomerRefreshRequest)
}

extension EndpointMock: RequestProtocol {
    var path: String {
        switch self {
        case .NoEndpoint:
            return "/no_endpoint"
        case .WalkthroughsList:
            return "/walk_throughs/list"
        case .TagsList:
            return "/tags/list"
        case .CustomerRefresh:
            return "/customers/refresh"
        }
    }

    var httpMethod: String {
        switch self {
        case .NoEndpoint, .WalkthroughsList, .TagsList:
            return "GET"
        case .CustomerRefresh:
            return "POST"
        }
    }

    var body: Encodable? {
        switch self {
        case .NoEndpoint, .WalkthroughsList, .TagsList:
            return nil
        case .CustomerRefresh(let body):
            return body
        }
    }

    var queryParameter: Encodable? {
        return nil
    }
}
