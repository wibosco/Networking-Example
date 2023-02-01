//
//  NetworkingConfiguration.swift
//  Networking
//
//  Created by William Boles on 31/01/2023.
//

import Foundation

public protocol HTTPNetworkingConfigurationType {
    //TODO: Determine if these are the correct names?
    var scheme: String { get }
    var host: String { get }
}

public struct HTTPNetworkingConfiguration: HTTPNetworkingConfigurationType {
    public let scheme: String
    public let host: String
    
    // MARK: - Init
    
    public init(scheme: String,
                host: String) {
        self.scheme = scheme
        self.host = host
    }
}
