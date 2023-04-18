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
            TextField(NSLocalizedString(
                title, comment: ""), text: $searchBarText)
                .searchBoxText()
                .onTapGesture {
                    withAnimation(.spring()) {
                        self.searching = true
                    }
                }
                .onSubmit {
                    if let search = search {
                        search()
                    }
                    hideKeyboard()
                }
                .searchBox()
 
            if searching {
                Button(action: {
                    withAnimation(.spring()) {
                        self.searching = false
                    }
                    self.searchBarText = ""
                    hideKeyboard()
 
                }) {
                    Text(NSLocalizedString("Cancel", comment: ""))
                }
                .padding(.trailing, 25)
                .padding(.top, 5)
            }
        }
    }
}
