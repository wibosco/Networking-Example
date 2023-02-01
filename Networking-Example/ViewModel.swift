//
//  ViewModelProvider.swift
//  Networking-Example
//
//  Created by William Boles on 31/01/2023.
//

import Foundation

class ViewModel: ObservableObject {
    @Published var results: [SearchResult] = []
    
    private let galleryService: GalleryService
    
    // MARK: - Init
    
    init(galleryService: GalleryService) {
        self.galleryService = galleryService
    }
    
    // MARK: - Search
    
    func search(term: String) {
        galleryService.search(term: term) { searchResult in
            self.results = searchResult?.data ?? []
        }
    }
}
