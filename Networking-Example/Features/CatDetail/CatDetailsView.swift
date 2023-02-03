//
//  CatDetailsView.swift
//  Networking-Example
//
//  Created by William Boles on 03/02/2023.
//

import SwiftUI

struct CatDetailsView: View {
    @StateObject var dataProvider: CatDetailsDataProvider
    
    var body: some View {
        VStack {
            if dataProvider.retrievingDetails {
                ProgressView("Loading Cat...")
            } else if let viewModel = dataProvider.viewModel {
                AsyncImage(url: viewModel.imageURL) { phase in
                    switch phase {
                    case .empty:
                        ProgressView()
                    case .success(let image):
                        image.resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
                            .clipped()
                    case .failure:
                        Image(systemName: "photo")
                    @unknown default:
                        Image(systemName: "photo")
                    }
                }
            } else {
                //TODO: handle better error
                Image(systemName: "photo")
            }
        }
        .task {
            await dataProvider.retrieveCatDetails()
        }
    }
}

//struct CatDetailsView_Previews: PreviewProvider {
//    static var previews: some View {
//        CatDetailsView()
//    }
//}
