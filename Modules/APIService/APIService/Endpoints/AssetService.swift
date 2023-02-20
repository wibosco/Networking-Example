//
//  AssetService.swift
//  APIService
//
//  Created by William Boles on 20/02/2023.
//

import Foundation
import Networking
import SwiftUI

public protocol AssetServiceType {
    func retrieveImage(from url: URL, progressUpdateHandler: ((Double) -> ())?) async -> Image
}


public class AssetService: AssetServiceType {
    let networkingClient: HTTPNetworkingClientType
    
    // MARK: - Init
    
    public init(networkingClient: HTTPNetworkingClientType) {
        self.networkingClient = networkingClient
    }
    
    // MARK: - Image
    
    public func retrieveImage(from url: URL,
                              progressUpdateHandler: ((Double) -> ())?) async -> Image {
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
}
