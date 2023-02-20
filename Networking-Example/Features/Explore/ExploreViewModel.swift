//
//  ViewModelProvider.swift
//  Networking-Example
//
//  Created by William Boles on 31/01/2023.
//

import Foundation
import APIService
import SwiftUI

enum ExploreState {
    case empty
    case retrieving
    case retrieved(_ viewModels: [CatViewModel])
    case failed
}

@MainActor
class ExploreViewModel: ObservableObject {
    @Published var state: ExploreState = .empty
    
    private let dependencies: DependencyContainer
    
    // MARK: - Init
    
    init(dependencies: DependencyContainer) {
        self.dependencies = dependencies
    }
    
    // MARK: - Retrieval
    
    func retrieveCats() async {
        state = .retrieving
        
        let cats = await dependencies.imagesService.retrieveExploreCats()
        let viewModels = buildViewModels(from: cats)
        
        state = .retrieved(viewModels)
    }
    
    func refreshCats() async {
        let cats = await dependencies.imagesService.retrieveExploreCats()
        let viewModels = buildViewModels(from: cats)
        
        state = .retrieved(viewModels)
    }
    
    private func buildViewModels(from cats: [Cat]) -> [CatViewModel] {
        return cats.map { CatViewModel(id: $0.id, url: $0.url) }
    }
    
    // MARK: - CatDetails
    
    func detailsViewModel(for id: String) -> CatDetailsViewModel {
        let viewModel = CatDetailsViewModel(id: id,
                                            dependencies: dependencies)
        
        return viewModel
    }
}

@MainActor
class CatViewModel {
    let id: String
    let url: URL
    
    // MARK: - Init
    
    init(id: String, url: URL) {
        self.id = id
        self.url = url
    }
}
