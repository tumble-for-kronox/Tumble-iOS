//
//  SearchBar.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 11/17/22.
//

import SwiftUI

struct SearchBar: View {
    @EnvironmentObject var viewModel: SearchParentView.SearchViewModel
    @State private var closeButtonOffset: CGFloat = 300.0
    @State private var hasTimeElapsed: Bool = false
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)
                .font(.headline)
                .padding(.leading, 5)
            TextField("Search schedules", text: $viewModel.searchBarText)
                .searchBoxText()
                .onTapGesture {
                    self.animateCloseButtonIntoView()
                }
            Button(action: {
                if (viewModel.searchBarText.isEmpty) {
                    hideKeyboard()
                    self.animateCloseButtonOutOfView()
                }
                viewModel.onClearSearch(endEditing: viewModel.searchBarText.isEmpty)
                
            }) {
                Image(systemName: "xmark.circle")
                    .foregroundColor(Color("PrimaryColor"))
                    .font(.headline)
            }
            .offset(x: closeButtonOffset)
        }
        .searchBox()
    }
    
    private func animateCloseButtonIntoView() -> Void {
        if self.closeButtonOffset == 300.0 {
            withAnimation(.spring().delay(0.5)) {
                self.closeButtonOffset -= 300
            }
        }
    }
    
    private func animateCloseButtonOutOfView() -> Void {
        withAnimation(.spring().delay(0.5)) {
            self.closeButtonOffset += 300
        }
    }
    
}
