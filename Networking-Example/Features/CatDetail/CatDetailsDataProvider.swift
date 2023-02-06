//
//  CatDetailsDataProvider.swift
//  Networking-Example
//
//  Created by William Boles on 03/02/2023.
//

import Foundation
import APIService

class CatDetailsDataProvider: ObservableObject {
    @Published var viewModel: CatDetailViewModel?
    @Published var retrievingDetails: Bool = false
    
    let id: String
    
    private let service: ImagesServiceType
    
    // MARK: - Init
    
    init(id: String,
         service: ImagesServiceType) {
        self.id = id
        self.service = service
    }
    
    // MARK: - Retrieval
    
    @MainActor
    func retrieveCatDetails() async {
        retrievingDetails = true
        
        let catImage = await service.retrieveCat(for: id)
        
        self.viewModel = CatDetailViewModel(id: catImage.id, imageURL: catImage.url)
        
        retrievingDetails = false
    }
}

struct CatDetailViewModel: Identifiable {
    var id: String
    var imageURL: URL
}
