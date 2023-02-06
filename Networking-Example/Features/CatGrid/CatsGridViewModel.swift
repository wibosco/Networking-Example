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
class CatsGridDataProvider: ObservableObject {
    @Published var viewModels: [CatViewModel] = []
    @Published var retrievingCats: Bool = false
    
    let service: ImagesServiceType //TODO: Should be private
    
    // MARK: - Init
    
    init(service: ImagesServiceType) {
        self.service = service
    }
    
    // MARK: - Retrieval
    
    func retrieveCats() async {
        retrievingCats = true
        
        let cats = await service.retrieveCats()
        self.viewModels = buildViewModels(from: cats)
        
        retrievingCats = false
    }
    
    func refreshCats() async {
        let cats = await service.retrieveCats()
        self.viewModels = buildViewModels(from: cats)
    }
    
    private func buildViewModels(from cats: [Cat]) -> [CatViewModel] {
        return cats.map { CatViewModel(id: $0.id, url: $0.url, service: service) }
    }
}

enum ImageRetrievalState {
    case empty
    case retrieving
    case retrieved(_ image: Image)
    case failed
}

@MainActor
class CatViewModel: ObservableObject {
    let id: String
    let url: URL
    
    @Published var state: ImageRetrievalState = .empty
    
    private let service: ImagesServiceType
    
    // MARK: - Init
    
    init(id: String, url: URL, service: ImagesServiceType) {
        self.id = id
        self.url = url
        self.service = service
    }
    
    // MARK: - Image
    
    func retrieveImage() async {
        state = .retrieving
        
        let image = await service.retrieveImage(from: url)
        
        state = .retrieved(image)
    }
}
