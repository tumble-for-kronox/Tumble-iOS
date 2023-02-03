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
    let resetSearchResults: () -> Void
    
    var body: some View {
        Button(action: {
            self.presentationMode.wrappedValue.dismiss()
            resetSearchResults()
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
