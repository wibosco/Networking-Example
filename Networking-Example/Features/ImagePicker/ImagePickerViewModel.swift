//
//  ImagePickerViewModel.swift
//  Networking-Example
//
//  Created by William Boles on 08/02/2023.
//

import Foundation
import APIService
import UIKit

enum ImageUploadState {
    case ready
    case uploading
}

@MainActor
class ImagePickerViewModel: ObservableObject {
    @Published var state: ImageUploadState = .ready
    
    private let dependencies: DependencyContainer

    // MARK: - Init
    
    init(dependencies: DependencyContainer) {
        self.dependencies = dependencies
    }
    
    // MARK: - Upload
    
    func uploadImage(_ image: UIImage) async {
        state = .uploading
        await dependencies.imagesService.uploadCatJPEGImage(image)
        state = .ready
    }
}
