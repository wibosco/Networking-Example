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
                                        let catDetailsDataProvider = CatDetailsDataProvider(id: catViewModel.id,
                                                                                            service: dataProvider.service)
                                        CatDetailsView(dataProvider: catDetailsDataProvider)
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
        VStack {
            switch viewModel.state {
            case .empty:
                //TODO: Implement placeholder image
                EmptyView()
            case .retrieving:
                ProgressView()
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
        .task {
            await viewModel.retrieveImage()
        }
    }
}

//struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        ContentView()
//    }
//}
