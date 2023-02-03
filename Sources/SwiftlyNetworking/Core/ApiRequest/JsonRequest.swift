//
//  JsonRequestProtocol.swift
//
//
//  Created by Onur Var on 3.02.2023.
//

import Foundation

class JsonRequest {
    // MARK: Variables

    var path: String
    var httpMethod: String
    var queryParameter: Encodable?
    var body: Encodable?
    var refreshTokenOnFailEnabled: Bool

    // MARK: Life Cycle

     init(
        path: String,
        httpMethod: String,
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
    var rRefreshTokenOnFailEnabled: Bool {
        return refreshTokenOnFailEnabled
    }

    var rPath: String {
        return path
    }

    var rHttpMethod: String {
        return httpMethod
    }

    var rQueryParameter: Encodable? {
        return queryParameter
    }

    var rBody: Data? {
        return body?.toJSONData()
    }

    var rHeaders: [String: String]? {
        return [
            "Content-Type": "application/json",
            "Accept": "application/json",
        ]
    }
}
