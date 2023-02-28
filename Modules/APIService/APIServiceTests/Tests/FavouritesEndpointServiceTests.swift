//
//  FavouritesEndpointServiceTests.swift
//  APIServiceTests
//
//  Created by William Boles on 27/02/2023.
//

import XCTest
import NetworkingTestHelpers

@testable import APIService

final class FavouritesEndpointServiceTests: XCTestCase {
    
    // MARK: - Tests
    
    func test_favourite_networkRequest() async {
        let networkingClient = StubHTTPNetworkingClient<FavouriteOutcome, FavouriteBody>()
        let sut = FavouritesEndpointService(networkingClient: networkingClient)
        
        let id = "abc123"
        
        let outcomeToBeReturned = FavouriteOutcome.testData()
        let expectedBody = FavouriteBody(id: id)
        
        let expecatation = expectation(description: "networking expectation")
        networkingClient.postJSONClosure = { (path, body, headers) in
            XCTAssertEqual(path, "/v1/favourites")
            XCTAssertEqual(body, expectedBody)
            XCTAssertNil(headers)
            
            expecatation.fulfill()
            
            return outcomeToBeReturned
        }
        
        let outcome = await sut.favourite(id: id)
        
        await waitForExpectations(timeout: 3)
        
        XCTAssertEqual(outcome, outcomeToBeReturned)
    }
}
