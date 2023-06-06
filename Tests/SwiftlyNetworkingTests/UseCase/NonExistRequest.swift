//
//  NonExistRequest.swift
//
//
//  Created by Onur Var on 3.02.2023.
//

@testable import SwiftlyNetworking

class NonExistRequest: JsonRequest {
    init() {
        super.init(path: "/no_endpoint", httpMethod: .POST)
    }
}
