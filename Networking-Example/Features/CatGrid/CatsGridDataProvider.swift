//
//  ViewModelProvider.swift
//  Networking-Example
//
//  Created by William Boles on 31/01/2023.
//

import Foundation
import APIService

class CatsGridDataProvider: ObservableObject {
    @Published var viewModels: [CatImageViewModel] = []
    @Published var retrievingCats: Bool = false
    
    let service: ImagesServiceType
    
    // MARK: - Init
    
    init(service: ImagesServiceType) {
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
    
    private func buildViewModels(from cats: [ImageResult]) -> [CatImageViewModel] {
        return cats.map { CatImageViewModel(id: $0.id, imageURL: $0.url) }
    }
}

struct CatImageViewModel: Identifiable {
    var id: String
    var imageURL: URL
}
