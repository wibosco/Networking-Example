//
//  NetworkingError.swift
//  Networking
//
//  Created by William Boles on 31/01/2023.
//

import Foundation

public enum NetworkingError: Error {
    case network(underlayingError: Error?, response: URLResponse?)
    case decoding(underlayingError: Error?)
    case encoding(underlayingError: Error?)
}

extension NetworkingError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .network(let underlyingError, let response):
            var localizedDescription = "Unable to retrieve content"
            if let response = response {
                if let url = response.url {
                    localizedDescription += " from \(url)"
                }
                if let httpResponse = response as? HTTPURLResponse {
                    localizedDescription += " received status code \(httpResponse.statusCode)"
                }
            }
            if let underlyingError = underlyingError {
                localizedDescription += " with underlaying error \(underlyingError.localizedDescription)"
            }
            
            return localizedDescription
        case .decoding(let underlyingError):
            var localizedDescription = "Unable to decode content"
            if let underlyingError = underlyingError {
                localizedDescription += " with underlaying error \(underlyingError.localizedDescription)"
            }
            
            return localizedDescription
        case .encoding(let underlyingError):
            var localizedDescription = "Unable to encode content"
            if let underlyingError = underlyingError {
                localizedDescription += " with underlaying error \(underlyingError.localizedDescription)"
            }
            
            return localizedDescription
        }
    }
}
