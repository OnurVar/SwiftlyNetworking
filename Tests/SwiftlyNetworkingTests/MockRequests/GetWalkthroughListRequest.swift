//
//  GetWalkthroughListRequest.swift
//
//
//  Created by Onur Var on 3.02.2023.
//

@testable import SwiftlyNetworking

class GetWalkthroughListRequest: JsonRequest {
    init() {
        super.init(path: "/walk_throughs/list", httpMethod: .GET)
    }
}
