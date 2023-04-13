//
//  SearchField.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 2023-04-12.
//

import SwiftUI

struct SearchField: View {
    
    let search: (() -> Void)?
    let title: String
    @Binding var searchBarText: String
    @Binding var searching: Bool
    @State private var closeButtonOffset: CGFloat = 300.0
    
    var body: some View {
        HStack {
            SearchButton(search: search)
            TextField(NSLocalizedString(
                title, comment: ""), text: $searchBarText,
                      onEditingChanged: onEditingChanged)
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
            if let search = search {
                search()
            }
            hideKeyboard()
        }
    }
    
    
    func onClearSearch(endEditing: Bool) -> Void {
        if searching {
            if searchBarText.isEmpty {
                withAnimation(.easeInOut) {
                    searching = false
                }
            } else {
                searchBarText = ""
            }
        } else {
            withAnimation(.easeInOut) {
                searching = false
            }
        }
    }
    
    func onEditingChanged(value: Bool) -> Void {
        if searchBarText.isEmpty {
            withAnimation(.easeOut) {
                searching = value
                animateCloseButtonIntoView()
            }
        } else {
            hideKeyboard()
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
