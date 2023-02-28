//
//  StubDecodable.swift
//  NetworkingTestHelpers
//
//  Created by William Boles on 27/02/2023.
//

import Foundation

public struct StubDecodable: Decodable {
    public let name: String
    
    // MARK: - Init
    
    public init() {
        name = "Stub Decodable"
    }
}
