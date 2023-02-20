//
//  CatDetailsView.swift
//  Networking-Example
//
//  Created by William Boles on 03/02/2023.
//

import SwiftUI

struct CatDetailsView: View {
    @StateObject var viewModel: CatDetailsViewModel
    
    var body: some View {
        VStack {
            switch viewModel.state {
            case .empty:
                //TODO: Implement placeholder image
                EmptyView()
            case .retrieving(let percentageRetrieved):
                VStack {
                    ProgressView(value: percentageRetrieved, total: 1)
                        .padding(.horizontal, 100)
                }
            case .retrieved(let image):
                image.resizable()
                    .aspectRatio(contentMode: .fill)
                        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
                        .clipped()
            case .failed:
                //TODO: Implement failed image
                EmptyView()
            }
        }
        .toolbar {
            Button("Favourite") {
                
            }
            .tint(.yellow)
            
        }
        .task {
            await viewModel.retrieveImage()
        }
    }
}
