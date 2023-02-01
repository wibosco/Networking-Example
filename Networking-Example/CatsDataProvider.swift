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
    
    // MARK: - Search
    
    @MainActor
    func retrieveCatImages() async {
        retrievingCats = true
        
        let cats = await service.retrieveCatImages()
        self.viewModels = cats.map { CatImageViewModel(id: $0.id, imageURL: $0.url) }
        
        retrievingCats = false
    }
}

struct CatImageViewModel: Identifiable {
    var id: String
    var imageURL: URL
}
