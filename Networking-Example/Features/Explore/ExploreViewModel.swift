//
//  ViewModelProvider.swift
//  Networking-Example
//
//  Created by William Boles on 31/01/2023.
//

import Foundation
import APIService
import SwiftUI

@MainActor
class ExploreViewModel: ObservableObject {
    @Published var viewModels: [CatViewModel] = []
    @Published var retrievingCats: Bool = false
    
    private let dependencies: DependencyContainer
    
    // MARK: - Init
    
    init(dependencies: DependencyContainer) {
        self.dependencies = dependencies
    }
    
    // MARK: - Retrieval
    
    func retrieveCats() async {
        retrievingCats = true
        
        let cats = await dependencies.imagesService.retrieveOthersCats()
        self.viewModels = buildViewModels(from: cats)
        
        retrievingCats = false
    }
    
    func refreshCats() async {
        let cats = await dependencies.imagesService.retrieveOthersCats()
        self.viewModels = buildViewModels(from: cats)
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
