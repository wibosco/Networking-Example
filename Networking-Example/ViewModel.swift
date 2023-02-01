//
//  ViewModelProvider.swift
//  Networking-Example
//
//  Created by William Boles on 31/01/2023.
//

import Foundation

class ViewModel: ObservableObject {
    @Published var results: [SearchResult] = []
    @Published var searching: Bool = false
    
    private let galleryService: GalleryService
    
    // MARK: - Init
    
    init(galleryService: GalleryService) {
        self.galleryService = galleryService
    }
    
    // MARK: - Search
    
    @MainActor
    func search(for searchText: String) async {
        searching = true
        self.results = await galleryService.search(for: searchText).data
        searching = false
    }
}
