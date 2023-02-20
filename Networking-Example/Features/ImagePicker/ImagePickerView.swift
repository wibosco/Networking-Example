//
//  ImagePickerView.swift
//  Networking-Example
//
//  Created by William Boles on 08/02/2023.
//

import SwiftUI
import PhotosUI

struct ImagePickerView: View {
    @State private var selectedItem: PhotosPickerItem?
    
    @StateObject var viewModel: ImagePickerViewModel
    
    var body: some View {
        switch viewModel.state {
        case .ready:
            VStack {
                PhotosPicker("Select cat to upload", selection: $selectedItem, matching: .images)
            }
            .onChange(of: selectedItem) { _ in
                Task {
                    if let data = try? await selectedItem?.loadTransferable(type: Data.self) {
                        guard let image = UIImage(data: data) else {
                            //TODO: Handle better
                            fatalError("Can not convert data into an image")
                        }
                       
                        await viewModel.uploadImage(image)
                    }
                }
            }
        case .uploading:
            ProgressView()
        }
    }
}
