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
    
    let onSearch: (String) -> Void
    let onClearSearch: (Bool) -> Void
    
    var body: some View {
        HStack {
            SearchButton(search: search)
            TextField(NSLocalizedString("Search schedules", comment: ""), text: $searchBarText)
                .searchBoxText()
                .onTapGesture {
                    self.animateCloseButtonIntoView()
                }
            CloseButton(
                onClearSearch: onClearSearch,
                animateCloseButtonOutOfView: animateCloseButtonOutOfView,
                closeButtonOffset: $closeButtonOffset,
                searchBarText: $searchBarText)
        }
        .searchBox()
        .onSubmit {
            search()
        }
    }
    
    func search() -> Void {
        if searchBoxNotEmpty() {
            onSearch(searchBarText)
        }
    }
    
    fileprivate func animateCloseButtonIntoView() -> Void {
        if self.closeButtonOffset == 300.0 {
            withAnimation(.spring().delay(0.5)) {
                self.closeButtonOffset -= 300
            }
        }
    }
    
    fileprivate func animateCloseButtonOutOfView() -> Void {
        withAnimation(.spring().delay(0.5)) {
            self.closeButtonOffset += 300
        }
    }
    
    fileprivate func searchBoxNotEmpty() -> Bool {
        return !searchBarText.trimmingCharacters(in: .whitespaces).isEmpty
    }
    
}
