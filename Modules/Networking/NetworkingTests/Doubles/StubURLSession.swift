//
//  StubURLSession.swift
//  NetworkingTests
//
//  Created by William Boles on 28/02/2023.
//

import Foundation

import Networking

class StubURLSession: URLSessionType {
    var dataClosure: ((URLRequest) -> (Data, URLResponse))!
    var bytesClosure: ((URLRequest) -> (URLSession.AsyncBytes, URLResponse))!
    
    func data(for request: URLRequest) async throws -> (Data, URLResponse) {
        dataClosure(request)
    }
    
    func bytes(for request: URLRequest) async throws -> (URLSession.AsyncBytes, URLResponse) {
        bytesClosure(request)
    }
}
