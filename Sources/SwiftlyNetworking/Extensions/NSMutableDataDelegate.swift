//
//  NSMutableDataDelegate.swift
//
//
//  Created by Onur Var on 3.02.2023.
//

import Foundation

extension NSMutableData {
    func appendString(_ string: String) {
        if let data = string.data(using: .utf8) {
            append(data)
        }
    }
}
