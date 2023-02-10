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
            let clientIDHeader = HTTPHeader(field: "x-api-key", value: "live_0PkFk40eBl9BPuHy6MYNcZtOLujI9DK5ROGrxQhm4Qo6u3M5Ozv40yreJhmgds7w")
            let headers = (defaultHeaders + [clientIDHeader])
            
            let config = HTTPNetworkingConfiguration(scheme: "https",
                                                     host: "api.thecatapi.com",
                                                     defaultHeaders: headers)
            
            let networkingClient = HTTPNetworkingClient(urlSession: URLSession.shared,
                                                        config: config)
            
            let imageService = ImagesEndpointService(networkingClient: networkingClient)
            
            let gridViewModel = CatsGridDataProvider(service: imageService)
            let imagePickerViewModel = ImagePickerViewModel(service: imageService)
            
            TabView {
                CatsGridView(dataProvider: gridViewModel)
                    .tabItem {
                        Label("Explore", systemImage: "magnifyingglass.circle")
                    }
                
                ImagePickerView(viewModel: imagePickerViewModel)
                    .tabItem {
                        Label("Image Picker", systemImage: "photo.circle")
                    }
            }
        }
    }
}
