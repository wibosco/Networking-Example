//
//  GalleryService.swift
//  Networking-Example
//
//  Created by William Boles on 31/01/2023.
//

import Foundation
import Networking

class GalleryService {
    var networkingClient: HTTPNetworkingClient?
    
    // MARK: - Search
    
    func search(for searchText: String) async -> SearchResults {
        let config = HTTPNetworkingConfiguration(scheme: "https",
                                                 host: "api.imgur.com")
        networkingClient = HTTPNetworkingClient(urlSession: URLSession.shared,
                                                config: config)
        
        let catQueryItem = URLQueryItem(name: "q_all", value: searchText)
        let typeQueryItem = URLQueryItem(name: "q_type", value: "jpg")
        
        let acceptHeader = HTTPHeader(field: "Accept", value: "application/json")
        let contentTypeHeader = HTTPHeader(field: "Content-Type", value: "application/json")
        let authHeader = HTTPHeader(field: "Authorization", value: "Client-ID 50b101150342433")
        
        do {
            let results: SearchResults = try await networkingClient!.get(path: "/3/gallery/search/",
                                                                         queryItems: [catQueryItem, typeQueryItem],
                                                                         headers: [acceptHeader, contentTypeHeader, authHeader],
                                                                         decoder: JSONDecoder())
            
            return results
        } catch {
            fatalError()
            //handle
        }
    }
}
