//
//  ContentView.swift
//  Networking-Example
//
//  Created by William Boles on 27/01/2023.
//

import SwiftUI
import Networking

struct ContentView: View {
    @State private var searchText = ""
    @StateObject var viewModel = ViewModel(galleryService: GalleryService())
    
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible()),
    ]
    
    var body: some View {
        NavigationStack {
            VStack {
                if viewModel.searching {
                    ProgressView("Searching for \"\(searchText)\"")
                } else {
                    GeometryReader { geometryReader in
                        let width = geometryReader.size.width / CGFloat(columns.count)
                        ScrollView {
                            LazyVGrid(columns: columns, alignment: .center, spacing: 4) {
                                ForEach(viewModel.results, id: \.id) { _ in
                                    Color.orange.frame(width: width, height: width)
                                }
                            }
                        }
                    }
                }
            }
            .padding()
            .navigationTitle("Search")
        }
        
        .searchable(text: $searchText, prompt: "Search Imgur for...")
        .autocorrectionDisabled(true)
        .autocapitalization(.none)
        .onSubmit(of: .search) {
            Task {
                await viewModel.search(for: searchText)
            }
        }
        
    }
}

struct SearchResults: Codable {
    let data: [SearchResult]
}

struct SearchResult: Codable {
    let id: String
    let title: String
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
