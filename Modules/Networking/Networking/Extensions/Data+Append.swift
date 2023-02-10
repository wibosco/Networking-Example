//
//  Data+Append.swift
//  Networking
//
//  Created by William Boles on 10/02/2023.
//

import Foundation

extension Data {
    mutating func append(_ newElement: String) {
        if let data = newElement.data(using: .utf8) {
            self.append(data)
        }
    }
}
