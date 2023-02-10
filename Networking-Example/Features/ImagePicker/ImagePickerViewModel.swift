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
    private let service: ImagesEndpointServiceType
    
    @Published var state: ImageUploadState = .ready
    
    // MARK: - Init
    
    init(service: ImagesEndpointServiceType) {
        self.service = service
    }
    
    // MARK: - Upload
    
    func uploadImage(_ image: UIImage) async {
        state = .uploading
        await service.uploadCatImage(image)
        state = .ready
    }
}
