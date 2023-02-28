//
//  HTTPNetworkingClientTests.swift
//  NetworkingTests
//
//  Created by William Boles on 28/02/2023.
//

import XCTest
import NetworkingTestHelpers

@testable import Networking

final class HTTPNetworkingClientTests: XCTestCase {
    var urlSession: StubURLSession!
    var configuration: HTTPNetworkingConfiguration!
    var defaultHeaders: [HTTPHeader]!
    
    var sut: HTTPNetworkingClient!
    
    // MARK: - Lifecycle
    
    override func setUpWithError() throws {
        urlSession = StubURLSession()
        defaultHeaders = [HTTPHeader(field: "testHeaderKey",
                                     value: "testHeaderValue")]
        
        configuration = HTTPNetworkingConfiguration(scheme: "http",
                                                    host: "example.com",
                                                    defaultHeaders: defaultHeaders)
        
        sut = HTTPNetworkingClient(urlSession: urlSession,
                                   config: configuration)
    }
    
    override func tearDownWithError() throws {
        urlSession = nil
        defaultHeaders = nil
        configuration = nil
        
        sut = nil
    }
    
    // MARK: - Tests
    
    // MARK: Get
    
    func test_get_networkRequestMade() async throws {
        let queryItemA = URLQueryItem(name: "aQueryItemName",
                                      value: "aQueryItemValue")
        
        let queryItemB = URLQueryItem(name: "aQueryItemName",
                                      value: "aQueryItemValue")
        
        let headerA = HTTPHeader(field: "aHeaderField",
                                 value: "aHeaderValue")
        
        let headerB = HTTPHeader(field: "bHeaderField",
                                 value: "bHeaderValue")
        
        let customHeaders = [headerA, headerB]
        
        let networkingExpectation = expectation(description: "networking expectation")
        urlSession.dataClosure = { (urlRequest) in
            let expectedURL = URL(string: "http://example.com/v1/test?aQueryItemName=aQueryItemValue&aQueryItemName=aQueryItemValue")!
            
            XCTAssertEqual(urlRequest.url, expectedURL)
            
            let expectedHeaderCount = customHeaders.count + self.defaultHeaders.count
            XCTAssertEqual(urlRequest.allHTTPHeaderFields!.count, expectedHeaderCount)
            
            for header in self.defaultHeaders {
                XCTAssertEqual(urlRequest.allHTTPHeaderFields![header.field], header.value)
            }
            
            for header in customHeaders {
                XCTAssertEqual(urlRequest.allHTTPHeaderFields![header.field], header.value)
            }
            
            let urlResponse = HTTPURLResponse(url: expectedURL,
                                              statusCode: 200,
                                              httpVersion: nil,
                                              headerFields: nil)!
            let data = Bundle.loadJSONBundleFile("StubDecodable")
            
            networkingExpectation.fulfill()
            
            return (data, urlResponse)
        }
        
        let outcome: StubDecodable = try await sut.get(path: "/v1/test",
                                                       queryItems: [queryItemA, queryItemB],
                                                       headers: customHeaders,
                                                       decoder: JSONDecoder())
        
        await waitForExpectations(timeout: 3)
        
        XCTAssertEqual(outcome, StubDecodable(name: "Stubbed name"))
    }
    
    func test_getJSON_networkRequestMade() async throws {
        let queryItemA = URLQueryItem(name: "aQueryItemName",
                                      value: "aQueryItemValue")
        
        let queryItemB = URLQueryItem(name: "aQueryItemName",
                                      value: "aQueryItemValue")
        
        let headerA = HTTPHeader(field: "aHeaderField",
                                 value: "aHeaderValue")
        
        let headerB = HTTPHeader(field: "bHeaderField",
                                 value: "bHeaderValue")
        
        let customHeaders = [headerA, headerB]
        
        let networkingExpectation = expectation(description: "networking expectation")
        urlSession.dataClosure = { (urlRequest) in
            let expectedURL = URL(string: "http://example.com/v1/test?aQueryItemName=aQueryItemValue&aQueryItemName=aQueryItemValue")!
            
            XCTAssertEqual(urlRequest.url, expectedURL)
            
            let expectedHeaderCount = customHeaders.count + self.defaultHeaders.count + HTTPHeader.jsonHeaders().count
            XCTAssertEqual(urlRequest.allHTTPHeaderFields!.count, expectedHeaderCount)
            
            for header in self.defaultHeaders {
                XCTAssertEqual(urlRequest.allHTTPHeaderFields![header.field], header.value)
            }
            
            for header in customHeaders {
                XCTAssertEqual(urlRequest.allHTTPHeaderFields![header.field], header.value)
            }
            
            for header in HTTPHeader.jsonHeaders() {
                XCTAssertEqual(urlRequest.allHTTPHeaderFields![header.field], header.value)
            }
            
            let urlResponse = HTTPURLResponse(url: expectedURL,
                                              statusCode: 200,
                                              httpVersion: nil,
                                              headerFields: nil)!
            let data = Bundle.loadJSONBundleFile("StubDecodable")
            
            networkingExpectation.fulfill()
            
            return (data, urlResponse)
        }
        
        let outcome: StubDecodable = try await sut.getJSON(path: "/v1/test",
                                                           queryItems: [queryItemA, queryItemB],
                                                           headers: customHeaders)
        
        await waitForExpectations(timeout: 3)
        
        XCTAssertEqual(outcome, StubDecodable(name: "Stubbed name"))
    }
}
