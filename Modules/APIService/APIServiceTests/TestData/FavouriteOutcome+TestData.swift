//
//  FavouriteOutcome+TestData.swift
//  APIServiceTests
//
//  Created by William Boles on 27/02/2023.
//

import Foundation

@testable import APIService

extension FavouriteOutcome {
    static func testData(id: String = "favorite id",
                  message: String = "message") -> FavouriteOutcome {
        FavouriteOutcome(id: id,
                         message: message)
    }
}
