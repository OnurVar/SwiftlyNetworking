//
//  PostCustomerRefresh.swift
//
//
//  Created by Onur Var on 3.02.2023.
//

@testable import SwiftlyNetworking

class PostCustomerRefresh: JsonRequest {
    init(body: CustomerRefreshRequest) {
        super.init(path: "/customers/refresh", httpMethod: "POST", body: body)
    }
}
