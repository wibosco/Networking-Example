//
//  ImagesEndpointService+Image.swift
//  Networking-Example
//
//  Created by William Boles on 28/02/2023.
//

import Foundation
import APIService
import UIKit

extension ImagesEndpointServiceType {
    @discardableResult func uploadCatJPEGImage(_ image: UIImage) async -> CatUploadOutcome {
        guard let data = image.jpegData(compressionQuality: 1.0) else {
            //TODO: Handle better
            fatalError("Can not convery image to a jpeg")
        }
        
        let outcome = await uploadCatData(data, mimeType: .jpeg)
        
        return outcome
    }
}
