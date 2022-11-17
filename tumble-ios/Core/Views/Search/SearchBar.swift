//
//  SearchBar.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 11/17/22.
//

import SwiftUI

struct SearchBar: View {
    @EnvironmentObject var viewModel: SearchView.SearchViewModel
    var body: some View {
        HStack {
            TextField("Search schedules..", text: $viewModel.searchText)
                .padding(7)
                .padding(.horizontal, 25)
                .background(Color(.systemGray6))
                .cornerRadius(8)
                .padding(.horizontal, 10)
                .onTapGesture {
                    viewModel.isEditing = true
                    
                }
            if viewModel.isEditing {
                Button(action: {
                    viewModel.isEditing = false
                    viewModel.searchText = ""
                    
                }) {
                    Text("Cancel")
                    
                }
                .padding(.trailing, 10)
                .transition(.move(edge: .trailing))
                .animation(.default)
            }
        }
    }
    
    func search() -> Void {
        print("Searching!")
    }
}
