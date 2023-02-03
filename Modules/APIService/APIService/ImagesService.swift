//
//  ImagesService.swift
//  Networking-Example
//
//  Created by William Boles on 01/02/2023.
//

import Foundation
import Networking

public struct ImageResult: Decodable {
    public let id: String
    public let url: URL
}

public protocol ImagesServiceType {
    func retrieveCatImages() async -> [ImageResult]
    func retrieveCatImage(for id: String) async -> ImageResult
}

public class ImagesService: ImagesServiceType {
    let networkingClient: HTTPNetworkingClientType
    
    // MARK: - Init
    
    public init(networkingClient: HTTPNetworkingClientType) {
        self.networkingClient = networkingClient
    }
    
    // MARK: - Search
    
    public func retrieveCatImages() async -> [ImageResult] {
        let orderQueryItem = URLQueryItem(name: "order", value: "RANDOM")
        let mimeTypeQueryItem = URLQueryItem(name: "mime_types", value: "jpg")
        let limitQueryItem = URLQueryItem(name: "limit", value: "24")
        let includeBreedsQueryItem = URLQueryItem(name: "include_breeds", value: "false")
        let includeCategoriesQueryItem = URLQueryItem(name: "include_categories", value: "false")
        let sizeQueryItem = URLQueryItem(name: "size", value: "thumb")
        
        let queryItems = [orderQueryItem, mimeTypeQueryItem, limitQueryItem, includeBreedsQueryItem, includeCategoriesQueryItem, sizeQueryItem]
        
        do {
            let results: [ImageResult] = try await networkingClient.getJSON(path: "/v1/images/search",
                                                                            queryItems: queryItems,
                                                                            headers: nil)
            
            return results
        } catch let error {
            fatalError(error.localizedDescription)
            //handle
        }
    }
    
    // MARK: - Image
    
    public func retrieveCatImage(for id: String) async -> ImageResult {
        do {
            let sizeQueryItem = URLQueryItem(name: "size", value: "full")
            
            let result: ImageResult = try await networkingClient.getJSON(path: "/v1/images/\(id)",
                                                                         queryItems: [sizeQueryItem],
                                                                         headers: nil)
            
            return result
        } catch let error {
            fatalError(error.localizedDescription)
        }
    }
}
