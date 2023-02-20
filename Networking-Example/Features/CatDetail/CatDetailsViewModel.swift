//
//  CatDetailsDataProvider.swift
//  Networking-Example
//
//  Created by William Boles on 03/02/2023.
//

import Foundation
import APIService
import SwiftUI

enum ImageRetrievalState {
    case empty
    case retrieving(_ percentageRetrieved: Double)
    case retrieved(_ image: Image)
    case failed
}

@MainActor
class CatDetailsViewModel: ObservableObject {
    @Published var state: ImageRetrievalState = .empty
    
    private let id: String
    private let dependencies: DependencyContainer

    // MARK: - Init
    
    init(id: String,
        dependencies: DependencyContainer) {
        self.id = id
        self.dependencies = dependencies
    }
    
    // MARK: - Retrieval
    
    func retrieveImage() async {
        state = .retrieving(0)
        
        let cat = await dependencies.imagesService.retrieveCat(for: id)
        let image = await dependencies.assetService.retrieveImage(from: cat.url) { percentageRetrieved in
            Task {
                self.state = .retrieving(percentageRetrieved)
            }
        }
        
        state = .retrieved(image)
    }
    
    // MARK: - Favourite
    
    func favourite() async {
        _ = await dependencies.favouritesService.favourite(id: id)
    }
}
