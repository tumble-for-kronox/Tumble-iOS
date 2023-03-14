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
    @State private var hasTimeElapsed: Bool = false
    
    let onSearch: (String) -> Void
    let onClearSearch: (Bool) -> Void
    
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)
                .font(.system(size: 20))
                .padding(.leading, 5)
            TextField("Search schedules", text: $searchBarText)
                .searchBoxText()
                .onTapGesture {
                    self.animateCloseButtonIntoView()
                }
            Button(action: {
                if (searchBarText.isEmpty) {
                    hideKeyboard()
                    self.animateCloseButtonOutOfView()
                }
                onClearSearch(searchBarText.isEmpty)
                searchBarText = ""
                
            }) {
                Image(systemName: "xmark.circle")
                    .foregroundColor(Color("PrimaryColor"))
                    .font(.system(size: 20))
            }
            .offset(x: closeButtonOffset)
        }
        .searchBox()
        .onSubmit {
            if searchBoxNotEmpty() {
                onSearch(searchBarText)
            }
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
