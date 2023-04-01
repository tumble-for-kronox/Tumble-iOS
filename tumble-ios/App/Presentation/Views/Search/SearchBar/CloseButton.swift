//
//  CloseButton.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 4/1/23.
//

import SwiftUI

struct CloseButton: View {
    
    let onClearSearch: (Bool) -> Void
    let animateCloseButtonOutOfView: () -> Void
    
    @Binding var closeButtonOffset: CGFloat
    @Binding var searchBarText: String
    
    var body: some View {
        Button(action: {
            if (searchBarText.isEmpty) {
                hideKeyboard()
                animateCloseButtonOutOfView()
            }
            onClearSearch(searchBarText.isEmpty)
            searchBarText = ""
            
        }) {
            Image(systemName: "xmark.circle")
                .foregroundColor(Color.primary)
                .font(.system(size: 20))
        }
        .offset(x: closeButtonOffset)
    }
}
