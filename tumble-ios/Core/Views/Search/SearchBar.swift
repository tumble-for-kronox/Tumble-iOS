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
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)
                .font(.headline)
                .padding(.leading, 5)
            TextField("Search schedules", text: $viewModel.searchBarText)
                .font(.title2)
                .padding(.leading, 5)
                .disableAutocorrection(true)
                .onTapGesture {
                    viewModel.isEditing = true
                }
            if viewModel.isEditing {
                Button(action: {
                    if (viewModel.searchBarText.isEmpty) {
                        hideKeyboard()
                    }
                    viewModel.onClearSearch(endEditing: viewModel.searchBarText.isEmpty)
                    
                }) {
                    Image(systemName: "xmark.circle")
                        .foregroundColor(Color("PrimaryColor"))
                        .font(.headline)
                    
                }
                .animation(.easeIn, value: viewModel.isEditing)
                .animation(.easeOut, value: !viewModel.isEditing)
            }
        }
        .padding(10)
        .background(.gray.opacity(0.25))
        .cornerRadius(10)
        .animation(.easeOut, value: viewModel.isEditing)
        .animation(.easeIn, value: !viewModel.isEditing)
        .padding(.leading, 20)
        .padding(.trailing, 20)
        .padding(.bottom, 35)
        .padding(.top, 25)
    }
}
