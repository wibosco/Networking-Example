//
//  NetworkingConfiguration.swift
//  Networking
//
//  Created by William Boles on 31/01/2023.
//

import Foundation

public protocol HTTPNetworkingConfigurationType {
    var scheme: String { get }
    var host: String { get }
    var defaultHeaders: [HTTPHeader] { get }
}

public struct HTTPNetworkingConfiguration: HTTPNetworkingConfigurationType {
    public let scheme: String
    public let host: String
    public let defaultHeaders: [HTTPHeader]
    
    // MARK: - Init
    
    public init(scheme: String,
                host: String,
                defaultHeaders: [HTTPHeader]) {
        self.scheme = scheme
        self.host = host
        self.defaultHeaders = defaultHeaders
    }
}
