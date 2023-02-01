//
//  ContentView.swift
//  Networking-Example
//
//  Created by William Boles on 27/01/2023.
//

import SwiftUI
import Networking

struct ContentView: View {
    @StateObject var viewModel = ViewModel(galleryService: GalleryService())
    
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundColor(.accentColor)
            Text("Hello, world!")
        }
        .padding()
        .onAppear {
            viewModel.search(term: "cats")
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
