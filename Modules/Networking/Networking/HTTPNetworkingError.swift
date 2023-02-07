//
//  NetworkingError.swift
//  Networking
//
//  Created by William Boles on 31/01/2023.
//

import Foundation

public enum HTTPNetworkingError: Error {
    case network(underlyingError: Error)
    case response(response: URLResponse)
    case decoding(underlyingError: Error)
    case encoding(underlyingError: Error)
}

extension HTTPNetworkingError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .network(let underlyingError):
            let localizedDescription = "Unable to retrieve content  with underlaying error \(underlyingError.localizedDescription)"
            
            return localizedDescription
        case .response(let response):
            var localizedDescription = "Unable to retrieve content"
            if let url = response.url {
                localizedDescription += " from \(url)"
            }
            if let httpResponse = response as? HTTPURLResponse {
                localizedDescription += " received status code \(httpResponse.statusCode)"
            }
            
            return localizedDescription
        case .decoding(let underlyingError):
            let localizedDescription = "Unable to decode content with underlaying error \(underlyingError.localizedDescription)"
            
            return localizedDescription
        case .encoding(let underlyingError):
            let localizedDescription = "Unable to encode content with underlaying error \(underlyingError.localizedDescription)"
            
            return localizedDescription
        }
    }
}
