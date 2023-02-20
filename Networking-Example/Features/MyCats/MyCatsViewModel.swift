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
    let service: ImagesEndpointServiceType
    
    @Published var state: MyCatsState = .empty
    
    // MARK: - Init
    
    init(service: ImagesEndpointServiceType) {
        self.service = service
    }
    
    // MARK: - Retrieval

    func retrieveCats() async {
        state = .retrieving
        
        let cats = await service.retrieveMyCats()
        let viewModels = buildViewModels(from: cats)
        
        state = .retrieved(viewModels)
    }
    
    func refreshCats() async {
        let cats = await service.retrieveMyCats()
        let viewModels = buildViewModels(from: cats)
        
        state = .retrieved(viewModels)
    }
    
    private func buildViewModels(from cats: [Cat]) -> [MyCatViewModel] {
        return cats.map { MyCatViewModel(id: $0.id, url: $0.url) }
    }
}

@MainActor
struct MyCatViewModel {
    let id: String
    let url: URL
}
