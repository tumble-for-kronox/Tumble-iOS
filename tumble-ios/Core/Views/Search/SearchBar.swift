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
                .padding(.leading, 5)
            TextField("Search schedules", text: $viewModel.searchText)
                .font(.headline)
                .disableAutocorrection(true)
                .onTapGesture {
                    viewModel.isEditing = true
                }
            if viewModel.isEditing {
                Button(action: {
                    viewModel.clearSearch()
                    
                }) {
                    Image(systemName: "xmark.circle")
                        .foregroundColor(Color("PrimaryColor"))
                    
                }
                .padding(.trailing, 10)
                .transition(.move(edge: .trailing))
                .animation(.easeInOut)
            }
        }
        .padding(10)
        .background(.gray.opacity(0.25))
        .cornerRadius(10)
        }
    }
