//
//  BackButton.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 11/18/22.
//

import SwiftUI

struct BackButton: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    var body: some View {
        Button(action: {
            self.presentationMode.wrappedValue.dismiss()
        }) {
            HStack {
                Spacer()
                Image(systemName: "chevron.left.circle")
                Text("Back")
                    .font(.headline)
            }
            .foregroundColor(Color("PrimaryColor"))
        }
    }
}
