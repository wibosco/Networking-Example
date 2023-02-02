//
//  ImagesService.swift
//  Networking-Example
//
//  Created by William Boles on 01/02/2023.
//

import Foundation
import Networking

struct SearchResult: Decodable {
    let id: String
    let url: URL
}

class ImagesService {
    var networkingClient: HTTPNetworkingClient?
    
    // MARK: - CatImages
    
    func retrieveCatImages() async -> [SearchResult] {
        let config = HTTPNetworkingConfiguration(scheme: "https",
                                                 host: "api.thecatapi.com")
        
        networkingClient = HTTPNetworkingClient(urlSession: URLSession.shared,
                                                config: config)
        
        let orderQueryItem = URLQueryItem(name: "order", value: "RANDOM")
        let mimeTypeQueryItem = URLQueryItem(name: "mime_types", value: "jpg")
        let limitQueryItem = URLQueryItem(name: "limit", value: "24")
        
        let acceptHeader = HTTPHeader(field: "Accept", value: "application/json")
        let contentTypeHeader = HTTPHeader(field: "Content-Type", value: "application/json")
        let authHeader = HTTPHeader(field: "x-api-key", value: "")
        
        do {
            let cats: [SearchResult] = try await networkingClient!.get(path: "/v1/images/search",
                                                                       queryItems: [orderQueryItem, mimeTypeQueryItem, limitQueryItem],
                                                                       headers: [acceptHeader, contentTypeHeader, authHeader],
                                                                       decoder: JSONDecoder())
            
            return cats
        } catch let error {
            fatalError(error.localizedDescription)
            //handle
        }
    }
}
