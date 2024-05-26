//
//  GetSpaceListRequest.swift
//
//
//  Created by Onur Var on 26.05.2024.
//

@testable import SwiftlyNetworking

class GetSpaceListRequest: JsonRequest {
    init() {
        super.init(path: "/spaces/list", httpMethod: .GET)
    }
}
