//
//  ContentView.swift
//  Networking-Example
//
//  Created by William Boles on 27/01/2023.
//

import SwiftUI
import APIService

struct ExploreView: View {
    @StateObject var viewModel: ExploreViewModel
    
    // MARK: - View
    

    
    var body: some View {
        NavigationStack {
            VStack {
                switch viewModel.state {
                case .empty:
                    Text("You haven't uploaded any cats")
                case .retrieving:
                    ProgressView("Loading Cats...")
                case .retrieved(let viewModels):
                    GeometryReader { geometryReader in
                        let columns = GridItem.threeFlexibleColumns()
                        let sideLength = geometryReader.size.width / CGFloat(columns.count)
                        ScrollView {
                            LazyVGrid(columns: columns, alignment: .center, spacing: 4) {
                                ForEach(viewModels, id: \.id) { catViewModel in
                                    NavigationLink {
                                        let detailsViewModel = viewModel.detailsViewModel(for: catViewModel.id)
                                        CatDetailsView(viewModel: detailsViewModel)
                                    } label: {
                                        CatImageCell(viewModel: catViewModel)
                                            .frame(width: sideLength, height: sideLength)
                                    }
                                }
                            }
                        }
                    }
                case .failed:
                    //TODO: Implement failed image
                    EmptyView()
                }
            }
            .padding()
            .navigationTitle("Explore")
        }
        .task {
            await viewModel.retrieveCats()
        }
        .refreshable {
            await viewModel.refreshCats()
        }
    }
}

struct CatImageCell: View {
    let viewModel: CatViewModel
    
    var body: some View {
        AsyncImage(url: viewModel.url) { phase in
            switch phase {
            case .empty:
                ProgressView()
            case .success(let image):
                image.resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
                    .clipped()
            case .failure:
                Image(systemName: "photo")
            @unknown default:
                Image(systemName: "photo")
            }
        }
    }
}
