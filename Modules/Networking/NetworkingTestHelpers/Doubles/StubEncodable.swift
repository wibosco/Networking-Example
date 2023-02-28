//
//  StubEncodable.swift
//  NetworkingTestHelpers
//
//  Created by William Boles on 27/02/2023.
//

import Foundation

public struct StubEncodable: Encodable, Equatable {
    public let name: String
    
    // MARK: - Init
    
    public init(name: String) {
        self.name = name
    }
    
    public init() {
        name = "Stub Encodable"
    }
}
