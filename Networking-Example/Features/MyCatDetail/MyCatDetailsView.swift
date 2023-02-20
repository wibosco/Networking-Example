//
//  MyCatDetailView.swift
//  Networking-Example
//
//  Created by William Boles on 10/02/2023.
//

import SwiftUI

struct MyCatDetailsView: View {
    @Environment(\.dismiss) var dismiss
    
    @StateObject var viewModel: MyCatDetailsViewModel
    @State private var showDeletionAlert = false
    
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
            case .deleting:
                ProgressView()
            }
        }
        .toolbar {
            Button("Delete", role: .destructive) {
                showDeletionAlert = true
            }
            .tint(.red)
            .disabled(!viewModel.canDelete)
            .alert("Confirmation", isPresented: $showDeletionAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Delete", role: .destructive) { delete() }
            } message: {
                Text("Are you sure you want to delete this cat?")
            }
        }
        .task {
            await viewModel.retrieveImage()
        }
    }
    
    // MARK: - Deletion
    
    private func delete() {
        Task {
            await viewModel.deleteCat()
            dismiss()
        }
    }
}

//struct MyCatDetailView_Previews: PreviewProvider {
//    static var previews: some View {
//        MyCatDetailView()
//    }
//}
