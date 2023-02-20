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
    private let dependencies: DependencyContainer
    
    @Published var state: MyCatDetailsImageRetrievalState = .empty
    @Published var canDelete: Bool = false
    
    // MARK: - Init
    
    init(id: String,
         dependencies: DependencyContainer) {
        self.id = id
        self.dependencies = dependencies
    }
    
    // MARK: - Retrieval

    func retrieveImage() async {
        canDelete = false
        state = .retrieving(0)
        
        let cat = await dependencies.imagesService.retrieveCat(for: id)
        let image = await dependencies.imagesService.retrieveImage(from: cat.url) { percentageRetrieved in
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
        await dependencies.imagesService.deleteCat(id)
    }
}
