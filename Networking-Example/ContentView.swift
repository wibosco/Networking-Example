//
//  ContentView.swift
//  Networking-Example
//
//  Created by William Boles on 27/01/2023.
//

import SwiftUI
import Networking

struct ContentView: View {
    @StateObject var dataProvider = CatsDataProvider(service: ImagesService())
    
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
                        let width = geometryReader.size.width / CGFloat(columns.count)
                        ScrollView {
                            LazyVGrid(columns: columns, alignment: .center, spacing: 4) {
                                ForEach(dataProvider.viewModels, id: \.id) { viewModel in
                                    CatImageCell(viewModel: viewModel)
                                        .frame(width: width, height: width)
                                }
                            }
                        }
                    }
                }
            }
            .padding()
            .navigationTitle("Cats")
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

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
