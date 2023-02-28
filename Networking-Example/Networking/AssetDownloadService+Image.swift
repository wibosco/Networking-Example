//
//  AssetDownloadService+Image.swift
//  Networking-Example
//
//  Created by William Boles on 28/02/2023.
//

import Foundation
import APIService
import SwiftUI

extension AssetDownloadServiceType {
    public func retrieveImage(from url: URL,
                              progressUpdateHandler: ((Double) -> ())?) async -> Image {
        let data = await retrieveData(from: url, progressUpdateHandler: progressUpdateHandler)
        
        guard let uiImage = UIImage(data: data) else {
            //TODO: Handle better
            fatalError("Could not convert data to image")
        }
        
        let image = Image(uiImage: uiImage)
        
        return image
    }
}
