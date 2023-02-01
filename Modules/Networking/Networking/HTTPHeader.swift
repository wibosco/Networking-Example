//
//  HTTPHeaders.swift
//  Networking
//
//  Created by William Boles on 31/01/2023.
//

import Foundation

public struct HTTPHeader {
    let field: String
    let value: String
    
    // MARK: - Init
    
    public init(field: String, value: String) {
        self.field = field
        self.value = value
    }
}
