//
//  SearchField.swift
//  Tumble
//
//  Created by Adis Veletanlic on 2023-04-12.
//

import SwiftUI

/// Search field displayed on the Search
/// page of the app. Handles user input
/// when searching for specific schools.
struct SearchField: View {
    let search: (() -> Void)?
    let clearSearch: (() -> Void)?
    let title: String
    @Binding var searchBarText: String
    @Binding var searching: Bool
    @Binding var disabled: Bool
    @State private var closeButtonOffset: CGFloat = 300.0
    
    var body: some View {
        HStack {
            TextField(NSLocalizedString(
                title, comment: ""
            ), text: $searchBarText)
                .searchBoxText()
                .onTapGesture {
                    withAnimation(.spring()) {
                        self.searching = true
                    }
                }
                .disabled(disabled)
                .onSubmit(searchAction)
                .searchBox()
            if searching {
                HStack (spacing: 15) {
                    Button(action: searchAction) {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.onPrimary)
                            .font(.system(size: 16, weight: .semibold))
                    }
                    .buttonStyle(SearchMenuActionStyle())
                    Button(action: searchFieldAction) {
                        Image(systemName: "xmark")
                            .foregroundColor(.onPrimary)
                            .font(.system(size: 16, weight: .semibold))
                    }
                    .buttonStyle(SearchMenuActionStyle())
                }
                .padding(.trailing, 20)
                .padding(.top, 5)
            }
        }
    }
    
    func searchAction() {
        if let search = search {
            search()
        }
        hideKeyboard()
    }
    
    func searchFieldAction() {
        withAnimation(.easeInOut) {
            self.searching = false
        }
        if let clearSearch = clearSearch {
            clearSearch()
        }
        self.searchBarText = ""
        hideKeyboard()
    }
    
}
