//
//  FavouritesEndpointService.swift
//  APIService
//
//  Created by William Boles on 12/02/2023.
//

import Foundation
import Networking

public struct FavouriteOutcome: Decodable, Equatable {
    let id: String
    let message: String
}

public protocol FavouritesEndpointServiceType {
    @discardableResult func favourite(id: String) async -> FavouriteOutcome 
}

struct FavouriteBody: Encodable, Equatable {
    let id: String
    
    enum CodingKeys: String, CodingKey {
        case id = "image_id"
    }
}

public class FavouritesEndpointService: FavouritesEndpointServiceType {
    let networkingClient: HTTPNetworkingClientType
    
    // MARK: - Init
    
    public init(networkingClient: HTTPNetworkingClientType) {
        self.networkingClient = networkingClient
    }
    
    // MARK: Favourite
    
    public func favourite(id: String) async -> FavouriteOutcome {
        do {
            let body = FavouriteBody(id: id)
            let outcome: FavouriteOutcome = try await networkingClient.postJSON(path: "/v1/favourites",
                                                                                body: body,
                                                                                headers: nil)
            
            return outcome
        } catch let error {
            //TODO: Handle better
            fatalError(error.localizedDescription)
        }
    }
}
