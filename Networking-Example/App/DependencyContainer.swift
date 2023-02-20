//
//  DependencyContainer.swift
//  Networking-Example
//
//  Created by William Boles on 15/02/2023.
//

import Foundation
import Networking
import APIService

final class DependencyContainer {
    let networkingClient: HTTPNetworkingClientType
    let imagesService: ImagesEndpointServiceType
    let favouritesService: FavouritesEndpointServiceType
    let assetService: AssetServiceType
    
    // MARK: - Setup
    
    init() {
        self.networkingClient = DependencyContainer.setUpNetworking()
        
        self.imagesService = DependencyContainer.setUpImagesService(networkingClient: networkingClient)
        self.favouritesService = DependencyContainer.setUpFavouritesService(networkingClient: networkingClient)
        self.assetService = DependencyContainer.setUpAssetService(networkingClient: networkingClient)
    }
    
    // MARK: - Networking
    
    static func setUpNetworking() -> HTTPNetworkingClientType {
        let defaultHeaders = HTTPHeader.defaultHeaders()
        let clientIDHeader = HTTPHeader(field: "x-api-key", value: "live_0PkFk40eBl9BPuHy6MYNcZtOLujI9DK5ROGrxQhm4Qo6u3M5Ozv40yreJhmgds7w")
        let headers = (defaultHeaders + [clientIDHeader])
        
        let config = HTTPNetworkingConfiguration(scheme: "https",
                                                 host: "api.thecatapi.com",
                                                 defaultHeaders: headers)
        
        let networkingClient = HTTPNetworkingClient(urlSession: URLSession.shared,
                                                    config: config)
        
        return networkingClient
    }
    
    // MARK: - APIService
    
    static func setUpImagesService(networkingClient: HTTPNetworkingClientType) -> ImagesEndpointServiceType {
        let imagesService = ImagesEndpointService(networkingClient: networkingClient)
        
        return imagesService
    }
    
    static func setUpFavouritesService(networkingClient: HTTPNetworkingClientType) -> FavouritesEndpointServiceType {
        let favouritesService = FavouritesEndpointService(networkingClient: networkingClient)
        
        return favouritesService
    }
    
    static func setUpAssetService(networkingClient: HTTPNetworkingClientType) -> AssetServiceType {
        let assetService = AssetService(networkingClient: networkingClient)
        
        return assetService
    }
}
