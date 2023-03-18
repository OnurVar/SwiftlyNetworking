//
//  JsonRequestProtocol.swift
//
//
//  Created by Onur Var on 3.02.2023.
//

import Foundation

open class JsonRequest {
    // MARK: Variables

    private let path: String
    private let httpMethod: HttpMethodType
    private let queryParameter: Encodable?
    private let body: Encodable?
    private let refreshTokenOnFailEnabled: Bool

    // MARK: Life Cycle

    public init(
        path: String,
        httpMethod: HttpMethodType = .GET,
        queryParameter: Encodable? = nil,
        body: Encodable? = nil,
        refreshTokenOnFailEnabled: Bool = true
    ) {
        self.path = path
        self.httpMethod = httpMethod
        self.queryParameter = queryParameter
        self.body = body
        self.refreshTokenOnFailEnabled = refreshTokenOnFailEnabled
    }
}

extension JsonRequest: RequestProtocol {
    public var rRefreshTokenOnFailEnabled: Bool {
        return refreshTokenOnFailEnabled
    }

    public var rPath: String {
        return path
    }

    public var rHttpMethod: HttpMethodType {
        return httpMethod
    }

    public var rQueryParameter: Encodable? {
        return queryParameter
    }

    public var rBody: Data? {
        return body?.toJSONData()
    }

    public var rHeaders: [String: String]? {
        return [
            "Content-Type": "application/json",
            "Accept": "application/json",
        ]
    }
}
