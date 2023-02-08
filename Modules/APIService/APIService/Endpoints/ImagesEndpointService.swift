//
//  ImagesService.swift
//  Networking-Example
//
//  Created by William Boles on 01/02/2023.
//

import Foundation
import Networking
import SwiftUI

public struct Cat: Decodable {
    public let id: String
    public let url: URL
}

public struct CatUploadOutcome: Decodable {
    public let id: String
    public let url: URL
    public let pending: Bool
    public let approved: Bool
}

public protocol ImagesEndpointServiceType {
    func retrieveCats() async -> [Cat]
    func retrieveCat(for id: String) async -> Cat
    func retrieveImage(from url: URL, progressUpdateHandler: ((Double) -> ())?) async -> Image
    func uploadCatImage(_ image: UIImage) async -> CatUploadOutcome
}

public class ImagesEndpointService: ImagesEndpointServiceType {
    let networkingClient: HTTPNetworkingClientType
    
    // MARK: - Init
    
    public init(networkingClient: HTTPNetworkingClientType) {
        self.networkingClient = networkingClient
    }
    
    // MARK: - Images
    
    public func retrieveCats() async -> [Cat] {
        let orderQueryItem = URLQueryItem(name: "order", value: "RANDOM")
        let mimeTypeQueryItem = URLQueryItem(name: "mime_types", value: "jpg")
        let limitQueryItem = URLQueryItem(name: "limit", value: "24")
        let includeBreedsQueryItem = URLQueryItem(name: "include_breeds", value: "false")
        let includeCategoriesQueryItem = URLQueryItem(name: "include_categories", value: "false")
        let sizeQueryItem = URLQueryItem(name: "size", value: "thumb")
        
        let queryItems = [orderQueryItem, mimeTypeQueryItem, limitQueryItem, includeBreedsQueryItem, includeCategoriesQueryItem, sizeQueryItem]
        
        do {
            let results: [Cat] = try await networkingClient.getJSON(path: "/v1/images/search",
                                                                    queryItems: queryItems,
                                                                    headers: nil)
            
            return results
        } catch let error {
            fatalError(error.localizedDescription)
            //handle
        }
    }
    
    public func retrieveCat(for id: String) async -> Cat {
        do {
            let sizeQueryItem = URLQueryItem(name: "size", value: "full")
            
            let result: Cat = try await networkingClient.getJSON(path: "/v1/images/\(id)",
                                                                 queryItems: [sizeQueryItem],
                                                                 headers: nil)
            
            return result
        } catch let error {
            fatalError(error.localizedDescription)
        }
    }
    
    // MARK: - Image
    
    public func retrieveImage(from url: URL, progressUpdateHandler: ((Double) -> ())?) async -> Image {
        do {
            let data = try await networkingClient.downloadData(url: url,
                                                               progressThreshold: .everyTwenty,
                                                               progressUpdateHandler: { percentageRetrieved in
                progressUpdateHandler?(percentageRetrieved)
            })
            
            guard let uiImage = UIImage(data: data) else {
                //TODO: Handle better
                fatalError()
            }
            
            let image = Image(uiImage: uiImage)
            return image
        } catch let error {
            //TODO: Handle better
            fatalError(error.localizedDescription)
        }
    }
    
    @discardableResult public func uploadCatImage(_ image: UIImage) async -> CatUploadOutcome {
        do {
            let outcome: CatUploadOutcome = try await networkingClient.postImage(path: "/v1/images/upload",
                                                                                 image: image,
                                                                                 headers: nil,
                                                                                 decoder: JSONDecoder())
            
            return outcome
        } catch let error {
            //TODO: Handle better
            fatalError(error.localizedDescription)
        }
    }
}
