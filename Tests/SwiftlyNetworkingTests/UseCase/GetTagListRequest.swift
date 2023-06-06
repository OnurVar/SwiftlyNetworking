//
//  GetTagListRequest.swift
//
//
//  Created by Onur Var on 3.02.2023.
//

@testable import SwiftlyNetworking

class GetTagListRequest: JsonRequest {
    init() {
        super.init(path: "/tags/list", httpMethod: .POST)
    }
}
