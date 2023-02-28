//
//  AssetServiceTests.swift
//  APIServiceTests
//
//  Created by William Boles on 27/02/2023.
//

import XCTest
import UIKit
import NetworkingTestHelpers

@testable import APIService

final class AssetDownloadServiceTests: XCTestCase {
    
    // MARK: - Tests
    
    func test_retrieveImage_networkRequest() async {
        let networkingClient = StubHTTPNetworkingClient<StubDecodable, StubEncodable>()
        let sut = AssetDownloadService(networkingClient: networkingClient)
        
        let urlToBePassedIn = URL(string: "http://example.com/cat.jpg")!
        let dataToBeReturned = "Test data".data(using: .utf8)!
        
        let progressValue = 20.0
        
        let networkingExpecatation = expectation(description: "networking expectation")
        networkingClient.downloadDataClosure = { (url, progressThreshold, progressUpdateHandler) in
            XCTAssertEqual(url, urlToBePassedIn)
            XCTAssertEqual(progressThreshold, .everyTwenty)
            
            networkingExpecatation.fulfill()
            
            progressUpdateHandler?(progressValue)
            
            return dataToBeReturned
        }
        
        let progressExpectation = expectation(description: "progress expectation")
        let data = await sut.retrieveData(from: urlToBePassedIn,
                                          progressUpdateHandler: { percentage in
            XCTAssertEqual(percentage, progressValue)
            
            progressExpectation.fulfill()
        })
        
        await waitForExpectations(timeout: 3)
        
        XCTAssertEqual(data, dataToBeReturned)
    }
}
