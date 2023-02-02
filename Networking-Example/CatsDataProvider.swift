//
//  ViewModelProvider.swift
//  Networking-Example
//
//  Created by William Boles on 31/01/2023.
//

import Foundation

class CatsDataProvider: ObservableObject {
    @Published var viewModels: [CatImageViewModel] = []
    @Published var retrievingCats: Bool = false
    
    private let service: ImagesService
    
    // MARK: - Init
    
    init(service: ImagesService) {
        self.service = service
    }
    
    // MARK: - Retrieval
    
    @MainActor
    func retrieveCats() async {
        retrievingCats = true
        
        let cats = await service.retrieveCatImages()
        self.viewModels = buildViewModels(from: cats)
        
        retrievingCats = false
    }
    
    @MainActor
    func refreshCats() async {
        let cats = await service.retrieveCatImages()
        self.viewModels = buildViewModels(from: cats)
    }
    
    private func buildViewModels(from cats: [SearchResult]) -> [CatImageViewModel] {
        return cats.map { CatImageViewModel(id: $0.id, imageURL: $0.url) }
    }
}

struct CatImageViewModel: Identifiable {
    var id: String
    var imageURL: URL
}
