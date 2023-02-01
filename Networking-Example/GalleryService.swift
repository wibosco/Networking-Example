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
    
    func search(term: String, completion: @escaping (SearchResults?) -> ()) {
        let clientId = "50b101150342433"
        let config = HTTPNetworkingConfiguration(clientId: clientId,
                                                 scheme: "https",
                                                 host: "api.imgur.com")
        networkingClient = HTTPNetworkingClient(urlSession: URLSession.shared,
                                                config: config)
            
        let catQueryItem = URLQueryItem(name: "q_all", value: term)
        let typeQueryItem = URLQueryItem(name: "q_type", value: "jpg")
        
        let acceptHeader = HTTPHeader(field: "Accept", value: "application/json")
        let contentTypeHeader = HTTPHeader(field: "Content-Type", value: "application/json")
        let authHeader = HTTPHeader(field: "Authorization", value: "Client-ID \(clientId)")
        
        networkingClient?.get(path: "/3/gallery/search/",
                             queryItems: [catQueryItem, typeQueryItem],
                             headers: [acceptHeader, contentTypeHeader, authHeader],
                             decoder: JSONDecoder()) { (result: Result<SearchResults, Error>) in
            completion(SearchResults(data: []))
        }
    }
}
