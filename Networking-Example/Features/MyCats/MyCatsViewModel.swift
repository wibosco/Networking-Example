//
//  MyCatsViewModel.swift
//  Networking-Example
//
//  Created by William Boles on 10/02/2023.
//

import Foundation
import APIService
import SwiftUI

enum MyCatsState {
    case empty
    case retrieving
    case retrieved(_ viewModels: [MyCatViewModel])
    case failed
}

@MainActor
class MyCatsViewModel: ObservableObject {
    @Published var state: MyCatsState = .empty
    
    private let dependencies: DependencyContainer

    // MARK: - Init
    
    init(dependencies: DependencyContainer) {
        self.dependencies = dependencies
    }
    
    // MARK: - Retrieval

    func retrieveCats() async {
        state = .retrieving
        
        let cats = await dependencies.imagesService.retrieveMyCats()
        let viewModels = buildViewModels(from: cats)
        
        state = .retrieved(viewModels)
    }
    
    func refreshCats() async {
        let cats = await dependencies.imagesService.retrieveMyCats()
        let viewModels = buildViewModels(from: cats)
        
        state = .retrieved(viewModels)
    }
    
    private func buildViewModels(from cats: [Cat]) -> [MyCatViewModel] {
        return cats.map { MyCatViewModel(id: $0.id, url: $0.url) }
    }
    
    // MARK: - Details
    
    func detailsViewModel(for id: String) -> MyCatDetailsViewModel
    {
        let viewModel = MyCatDetailsViewModel(id: id,
                                              dependencies: dependencies)
        
        return viewModel
    }
}

@MainActor
struct MyCatViewModel {
    let id: String
    let url: URL
}
