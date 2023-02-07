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
                                ForEach(dataProvider.viewModels, id: \.id) { catViewModel in
                                    NavigationLink {
                                        let detailsViewModel = CatDetailsViewModel(id: catViewModel.id,
                                                                                   service: dataProvider.service)
                                        CatDetailsView(viewModel: detailsViewModel)
                                    } label: {
                                        CatImageCell(viewModel: catViewModel)
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
    @StateObject var viewModel: CatViewModel
    
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

//struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        ContentView()
//    }
//}
