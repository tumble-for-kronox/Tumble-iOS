//
//  SearchField.swift
//  Tumble
//
//  Created by Adis Veletanlic on 2023-04-12.
//

import SwiftUI

/// Search field displayed on the Search
/// page of the app. Handles user input
/// when searching for specific schools.®
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
                .onSubmit {
                    if let search = search {
                        search()
                    }
                    hideKeyboard()
                }
                .searchBox()
            if searching {
                Button(action: searchFieldAction) {
                    Text(NSLocalizedString("Cancel", comment: ""))
                        .font(.system(size: 16, weight: .semibold))
                }
                .padding(.trailing, 25)
                .padding(.top, 5)
            }
        }
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
