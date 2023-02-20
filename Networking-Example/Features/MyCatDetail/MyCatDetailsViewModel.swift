//
//  MyCatDetailsViewModel.swift
//  Networking-Example
//
//  Created by William Boles on 10/02/2023.
//

import Foundation
import APIService
import SwiftUI

enum MyCatDetailsImageRetrievalState: Equatable {
    case empty
    case retrieving(_ percentageRetrieved: Double)
    case retrieved(_ image: Image)
    case failed
    case deleting
}

@MainActor
class MyCatDetailsViewModel: ObservableObject {
    private let id: String
    private let service: ImagesEndpointServiceType
    
    @Published var state: MyCatDetailsImageRetrievalState = .empty
    @Published var canDelete: Bool = false
    
    // MARK: - Init
    
    init(id: String,
         service: ImagesEndpointServiceType) {
        self.id = id
        self.service = service
    }
    
    // MARK: - Retrieval

    func retrieveImage() async {
        canDelete = false
        state = .retrieving(0)
        
        let cat = await service.retrieveCat(for: id)
        let image = await service.retrieveImage(from: cat.url) { percentageRetrieved in
            Task {
                self.state = .retrieving(percentageRetrieved)
            }
        }
        
        state = .retrieved(image)
        canDelete = true
    }
    
    // MARK: - Delete
    
    func deleteCat() async {
        canDelete = false
        await service.deleteCat(id)
    }
}
