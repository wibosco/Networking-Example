//
//  Networking_ExampleApp.swift
//  Networking-Example
//
//  Created by William Boles on 27/01/2023.
//

import SwiftUI
import Networking
import APIService

@main
struct Networking_ExampleApp: App {
    var body: some Scene {
        WindowGroup {
            let defaultHeaders = HTTPHeader.defaultHeaders()
            let clientIDHeader = HTTPHeader(field: "x-api-key", value: "")
            let headers = (defaultHeaders + [clientIDHeader])
            
            let config = HTTPNetworkingConfiguration(scheme: "https",
                                                     host: "api.thecatapi.com",
                                                     defaultHeaders: headers)
            
            let networkingClient =  HTTPNetworkingClient(urlSession: URLSession.shared,
                                                         config: config)
            
            let imageService = ImagesEndpointService(networkingClient: networkingClient)
            
            let dataProvider = CatsGridDataProvider(service: imageService)
            CatsGridView(dataProvider: dataProvider)
        }
    }
}
