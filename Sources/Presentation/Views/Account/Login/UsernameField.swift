//
//  UsernameField.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 2023-02-12.
//

import SwiftUI

struct UsernameField: View {
    @Binding var username: String
    
    var body: some View {
        HStack {
            Image(systemName: "person")
                .foregroundColor(.onBackground.opacity(0.75))
            TextField(NSLocalizedString("Username/Email address", comment: ""), text: $username)
                .foregroundColor(.onBackground)
                .autocapitalization(.none)
                .disableAutocorrection(true)
                .keyboardType(.emailAddress)
            Spacer()
        }
        .padding(10)
        .overlay(RoundedRectangle(
            cornerRadius: 10)
            .stroke(lineWidth: 0.5)
            .foregroundColor(.onBackground.opacity(0.5)
            )
        )
        .padding(.bottom, 10)
    }
}
