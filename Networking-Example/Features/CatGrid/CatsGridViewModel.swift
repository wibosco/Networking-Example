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
    
    let service: ImagesEndpointServiceType //TODO: Should be private or an environment var
    
    // MARK: - Init
    
    init(service: ImagesEndpointServiceType) {
        self.service = service
    }
    
    // MARK: - Retrieval
    
    func retrieveCats() async {
        retrievingCats = true
        
        let cats = await service.retrieveOthersCats()
        self.viewModels = buildViewModels(from: cats)
        
        retrievingCats = false
    }
    
    func refreshCats() async {
        let cats = await service.retrieveOthersCats()
        self.viewModels = buildViewModels(from: cats)
    }
    
    private func buildViewModels(from cats: [Cat]) -> [CatViewModel] {
        return cats.map { CatViewModel(id: $0.id, url: $0.url) }
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
