//
//  APIServiceTests.swift
//  APIServiceTests
//
//  Created by William Boles on 02/02/2023.
//

import XCTest
import NetworkingTestHelpers

@testable import APIService

final class ImagesEndpointServiceTests: XCTestCase {
    
    // MARK: - Tests
    
    // MARK: RetrieveMyCats
    
    func test_retrieveMyCats_networkRequest() async {
        let networkingClient = StubHTTPNetworkingClient<[Cat], StubEncodable>()
        let sut = ImagesEndpointService(networkingClient: networkingClient)
        
        let catsToBeReturned: [Cat] = Cat.testData()
        
        let orderQueryItem = URLQueryItem(name: "order", value: "DESC")
        let limitQueryItem = URLQueryItem(name: "limit", value: "10")
        let formatQueryItem = URLQueryItem(name: "format", value: "json")
        
        let expectedQueryItems = [orderQueryItem, limitQueryItem, formatQueryItem]
        
        let expectation = expectation(description: "networking expectation")
        networkingClient.getJSONClosure = { (path, queryItems, headers) in
            XCTAssertEqual(path, "/v1/images")
            XCTAssertEqual(queryItems, expectedQueryItems)
            XCTAssertNil(headers)
            
            expectation.fulfill()
            
            return catsToBeReturned
        }
        
        let cats = await sut.retrieveMyCats()
            
        await waitForExpectations(timeout: 3)
        
        XCTAssertEqual(cats, catsToBeReturned)
    }
    
    // MARK: Delete
    
    func test_deleteCat_networkRequest() async {
        let networkingClient = StubHTTPNetworkingClient<StubDecodable, StubEncodable>()
        let sut = ImagesEndpointService(networkingClient: networkingClient)
        
        let id = "123456"
        
        let expectation = expectation(description: "networking expectation")
        networkingClient.deleteClosure = { (path, queryItems, headers) in
            XCTAssertEqual(path, "/v1/images/\(id)")
            XCTAssertNil(queryItems)
            XCTAssertNil(headers)
            
            expectation.fulfill()
        }
        
        await sut.deleteCat(id)
        
        await waitForExpectations(timeout: 3)
    }
    
    // MARK: Explore
    
    func test_retrieveExploreCats_networkRequest() async {
        let networkingClient = StubHTTPNetworkingClient<[Cat], StubEncodable>()
        let sut = ImagesEndpointService(networkingClient: networkingClient)
        
        let catsToBeReturned: [Cat] = Cat.testData()
        
        let orderQueryItem = URLQueryItem(name: "order", value: "RANDOM")
        let mimeTypeQueryItem = URLQueryItem(name: "mime_types", value: "jpg")
        let limitQueryItem = URLQueryItem(name: "limit", value: "24")
        let includeBreedsQueryItem = URLQueryItem(name: "include_breeds", value: "false")
        let includeCategoriesQueryItem = URLQueryItem(name: "include_categories", value: "false")
        let sizeQueryItem = URLQueryItem(name: "size", value: "thumb")
        
        let expectedQueryItems = [orderQueryItem, mimeTypeQueryItem, limitQueryItem, includeBreedsQueryItem, includeCategoriesQueryItem, sizeQueryItem]
        
        let expectation = expectation(description: "networking expectation")
        networkingClient.getJSONClosure = { (path, queryItems, headers) in
            XCTAssertEqual(path, "/v1/images/search")
            XCTAssertEqual(queryItems, expectedQueryItems)
            XCTAssertNil(headers)
            
            expectation.fulfill()
            
            return catsToBeReturned
        }
        
        let cats = await sut.retrieveExploreCats()
            
        await waitForExpectations(timeout: 3)
        
        XCTAssertEqual(cats, catsToBeReturned)
    }
    
    // MARK: Cat
    
    func test_retrieveCat_networkRequest() async {
        let networkingClient = StubHTTPNetworkingClient<Cat, StubEncodable>()
        let sut = ImagesEndpointService(networkingClient: networkingClient)
        
        let id = "123456"
        
        let catToBeReturned: Cat = Cat.testData(id: "single cat")
        
        let sizeQueryItem = URLQueryItem(name: "size", value: "full")
        
        let expectedQueryItems = [sizeQueryItem]
        
        let expectation = expectation(description: "networking expectation")
        networkingClient.getJSONClosure = { (path, queryItems, headers) in
            XCTAssertEqual(path, "/v1/images/\(id)")
            XCTAssertEqual(queryItems, expectedQueryItems)
            XCTAssertNil(headers)
            
            expectation.fulfill()
            
            return catToBeReturned
        }
        
        let cat = await sut.retrieveCat(for: id)
        
        await waitForExpectations(timeout: 3)
        
        XCTAssertEqual(cat, catToBeReturned)
    }
    
    // MARK: Upload
    
    func test_uploadCatImage_networkRequest() async {
        let networkingClient = StubHTTPNetworkingClient<CatUploadOutcome, StubEncodable>()
        let sut = ImagesEndpointService(networkingClient: networkingClient)
        
        let outcomeToBeReturned = CatUploadOutcome.testData()
        
        let dataToBeUploaded = "Test Data".data(using: .utf8)!
        
        let expectation = expectation(description: "networking expectation")
        networkingClient.postFileClosure = { (path, data, mimeType, headers, decoder) in
            XCTAssertEqual(path, "/v1/images/upload")
            XCTAssertEqual(data, dataToBeUploaded)
            XCTAssertEqual(mimeType, .jpeg)
            XCTAssertNil(headers)
            XCTAssertTrue(decoder is JSONDecoder)
            
            expectation.fulfill()
            
            return outcomeToBeReturned
        }
        
        let outcome = await sut.uploadCatData(dataToBeUploaded, mimeType: .jpeg)
        
        await waitForExpectations(timeout: 3)
        
        XCTAssertEqual(outcome, outcomeToBeReturned)
    }
}
