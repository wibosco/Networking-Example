//
//  MyCatsView.swift
//  Networking-Example
//
//  Created by William Boles on 10/02/2023.
//

import SwiftUI

struct MyCatsView: View {
    @StateObject var viewModel: MyCatsViewModel
    
    // MARK: - View
    
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible()),
    ]
    
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
                        let sideLength = geometryReader.size.width / CGFloat(columns.count)
                        ScrollView {
                            LazyVGrid(columns: columns, alignment: .center, spacing: 4) {
                                ForEach(viewModels, id: \.id) { catViewModel in
                                    NavigationLink {
                                        let detailsViewModel = MyCatDetailsViewModel(id: catViewModel.id,
                                                                                     service: viewModel.service)
                                        MyCatDetailsView(viewModel: detailsViewModel)
                                    } label: {
                                        MyCatImageCell(viewModel: catViewModel)
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
            .navigationTitle("My Cats")
        }
        .onAppear {
            Task {
                await viewModel.retrieveCats()
            }
        }
        .refreshable {
            await viewModel.refreshCats()
        }
    }
}

struct MyCatImageCell: View {
    let viewModel: MyCatViewModel
    
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

//struct MyCatsView_Previews: PreviewProvider {
//    static var previews: some View {
//        MyCatsView()
//    }
//}
