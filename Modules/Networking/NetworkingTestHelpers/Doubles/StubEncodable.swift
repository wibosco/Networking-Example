//
//  StubEncodable.swift
//  NetworkingTestHelpers
//
//  Created by William Boles on 27/02/2023.
//

import Foundation

public struct StubEncodable: Encodable {
    let name: String
    
    // MARK: - Init
    
    init() {
        name = "Stub Encodable"
    }
}
