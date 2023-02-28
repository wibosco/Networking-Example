//
//  CatUploadOutcome+TestData.swift
//  APIServiceTests
//
//  Created by William Boles on 27/02/2023.
//

import Foundation

@testable import APIService

extension CatUploadOutcome {
    static func testData(id: String = "abc123",
                  url: URL = URL(string: "http://example.test/cat.jpg")!,
                  pending: Int = 1,
                  approved: Int = 0) -> CatUploadOutcome {
        CatUploadOutcome(id: id,
                         url: url,
                         pending: pending,
                         approved: approved)
    }
}
