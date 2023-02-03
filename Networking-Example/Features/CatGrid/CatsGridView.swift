//
//  ContentView.swift
//  Networking-Example
//
//  Created by William Boles on 27/01/2023.
//

import SwiftUI
import APIService

struct CatsGridView: View {
    @StateObject var dataProvider: CatsGridDataProvider
    
    // MARK: - View
    
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible()),
    ]
    
    var body: some View {
        NavigationStack {
            VStack {
                if dataProvider.retrievingCats {
                    ProgressView("Loading Cats...")
                } else {
                    GeometryReader { geometryReader in
                        let sideLength = geometryReader.size.width / CGFloat(columns.count)
                        ScrollView {
                            LazyVGrid(columns: columns, alignment: .center, spacing: 4) {
                                ForEach(dataProvider.viewModels, id: \.id) { viewModel in
                                    NavigationLink {
                                        let catDetailsDataProvider = CatDetailsDataProvider(id: viewModel.id,
                                                                                            service: dataProvider.service)
                                        CatDetailsView(dataProvider: catDetailsDataProvider)
                                    } label: {
                                        CatImageCell(viewModel: viewModel)
                                            .frame(width: sideLength, height: sideLength)
                                    }
                                }
                            }
                        }
                    }
                }
            }
            .padding()
            .navigationTitle("Explore")
        }
        .task {
            await dataProvider.retrieveCats()
        }
        .refreshable {
            await dataProvider.refreshCats()
        }
    }
}

struct CatImageCell: View {
    let viewModel: CatImageViewModel
    
    var body: some View {
        VStack {
            AsyncImage(url: viewModel.imageURL) { phase in
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
}

//struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        ContentView()
//    }
//}
