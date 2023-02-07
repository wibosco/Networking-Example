//
//  CatDetailsDataProvider.swift
//  Networking-Example
//
//  Created by William Boles on 03/02/2023.
//

import Foundation
import APIService
import SwiftUI

class CatDetailsViewModel: ObservableObject {
    private let id: String
    private let service: ImagesEndpointServiceType
    
    @Published var state: ImageRetrievalState = .empty
    
    // MARK: - Init
    
    init(id: String,
         service: ImagesEndpointServiceType) {
        self.id = id
        self.service = service
    }
    
    // MARK: - Retrieval
    
    @MainActor
    func retrieveImage() async {
        state = .retrieving(0)
        
        let cat = await service.retrieveCat(for: id)
        let image = await service.retrieveImage(from: cat.url) { percentageRetrieved in
            Task {
                self.state = .retrieving(percentageRetrieved)
            }
        }
        
        state = .retrieved(image)
    }
}

enum ImageRetrievalState {
    case empty
    case retrieving(_ percentageRetrieved: Double)
    case retrieved(_ image: Image)
    case failed
}
