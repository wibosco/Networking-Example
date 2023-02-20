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
    let dependencyContainer: DependencyContainer = {
        return DependencyContainer()
    }()
    
    var body: some Scene {
        WindowGroup {
            let exploreViewModel = ExploreViewModel(dependencies: dependencyContainer)
            let imagePickerViewModel = ImagePickerViewModel(dependencies: dependencyContainer)
            let myCatsViewModel = MyCatsViewModel(dependencies: dependencyContainer)
            
            TabView {
                ExploreView(viewModel: exploreViewModel)
                    .tabItem {
                        Label("Explore Cats", systemImage: "magnifyingglass.circle")
                    }
                
                ImagePickerView(viewModel: imagePickerViewModel)
                    .tabItem {
                        Label("Upload Your Cat", systemImage: "photo.circle")
                    }
                
                MyCatsView(viewModel: myCatsViewModel)
                    .tabItem {
                        Label("My Cats", systemImage: "person.crop.circle")
                    }
            }
        }
    }
}
