//
//  BackButton.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 11/18/22.
//

import SwiftUI

struct BackButton: View {
    
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    let previousPage: String
    let callback: (() -> Void)?
    
    init(previousPage: String, callback: (() -> Void)? = nil) {
        self.previousPage = previousPage
        self.callback = callback
    }
    
    var body: some View {
        Button(action: {
            self.presentationMode.wrappedValue.dismiss()
            if let resetSearchResults = callback {
                resetSearchResults()
            }
        }) {
            HStack {
                Spacer()
                Image(systemName: "chevron.backward")
                    .font(.system(size: 16, weight: .semibold))
                Text(previousPage)
                    .backButton()
            }
            .foregroundColor(.onBackground)
        }
    }
}
