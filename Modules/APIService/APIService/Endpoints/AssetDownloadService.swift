//
//  AssetService.swift
//  APIService
//
//  Created by William Boles on 20/02/2023.
//

import Foundation
import Networking

public protocol AssetDownloadServiceType {
    func retrieveData(from url: URL, progressUpdateHandler: ((Double) -> ())?) async -> Data
}


public class AssetDownloadService: AssetDownloadServiceType {
    let networkingClient: HTTPNetworkingClientType
    
    // MARK: - Init
    
    public init(networkingClient: HTTPNetworkingClientType) {
        self.networkingClient = networkingClient
    }
    
    // MARK: - Image
    
    public func retrieveData(from url: URL,
                             progressUpdateHandler: ((Double) -> ())?) async -> Data {
        do {
            let data = try await networkingClient.downloadData(url: url,
                                                               progressThreshold: .everyTwenty,
                                                               progressUpdateHandler: { percentageRetrieved in
                progressUpdateHandler?(percentageRetrieved)
            })
            
           return data
        } catch let error {
            //TODO: Handle better
            fatalError(error.localizedDescription)
        }
    }
}
