//
//  JWTApiEntity.swift
//
//
//  Created by Onur Var on 2.02.2023.
//

struct JWTApiEntity: Decodable {
    var token: String?
    var refresh_token: String?
}
