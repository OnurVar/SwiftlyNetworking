//
//  CodableExtension.swift
//
//
//  Created by Onur Var on 22.11.2023.
//

import Foundation

public extension Encodable {
    func toDictionary() -> [String: Any]? {
        if let data = try? JSONEncoder().encode(self) {
            if let dictionary = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any] {
                return dictionary
            }
        }
        return nil
    }

    func toQueryParameters() -> [URLQueryItem] {
        guard let dictionary = toDictionary() else {
            return []
        }

        var queryParameters: [URLQueryItem] = []
        for item in dictionary {
            let value = item.value

            switch value {
            case let stringValue as String:
                queryParameters.append(URLQueryItem(name: item.key, value: stringValue))
            case let stringArrayValue as [String]:
                for stringValue in stringArrayValue {
                    queryParameters.append(URLQueryItem(name: item.key, value: stringValue))
                }

            case let intValue as Int:
                queryParameters.append(URLQueryItem(name: item.key, value: "\(intValue)"))
            case let intArrayValue as [Int]:
                for intValue in intArrayValue {
                    queryParameters.append(URLQueryItem(name: item.key, value: "\(intValue)"))
                }

            case let doubleValue as Double:
                queryParameters.append(URLQueryItem(name: item.key, value: "\(doubleValue)"))
            case let doubleArrayValue as [Double]:
                for doubleValue in doubleArrayValue {
                    queryParameters.append(URLQueryItem(name: item.key, value: "\(doubleValue)"))
                }

            case let boolValue as Bool:
                queryParameters.append(URLQueryItem(name: item.key, value: boolValue ?"true" : "false"))
            case let boolArrayValue as [Bool]:
                for boolValue in boolArrayValue {
                    queryParameters.append(URLQueryItem(name: item.key, value: boolValue ?"true" : "false"))
                }

            default:
                break
            }
        }

        return queryParameters.sorted { item1, item2 in item1.name < item2.name }
    }

    func toJSONData() -> Data? {
        return try? JSONEncoder().encode(self)
    }
}
