//
//  SearchBar.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 11/17/22.
//

import SwiftUI

struct SearchBar: View {
    @Binding var searchBarText: String
    @State private var closeButtonOffset: CGFloat = 300.0
    @State private var searching: Bool = false
    
    let onSearch: (String) -> Void
    let onClearSearch: (Bool) -> Void
    
    var body: some View {
        SearchField(
            search: search,
            title: "Search schedules",
            searchBarText: $searchBarText,
            searching: $searching
        )
        .padding(.bottom, 15)
    }
    
    func search() -> Void {
        if searchBoxNotEmpty() {
            onSearch(searchBarText)
        }
    }
    
    fileprivate func searchBoxNotEmpty() -> Bool {
        return !searchBarText.trimmingCharacters(in: .whitespaces).isEmpty
    }
    
}
