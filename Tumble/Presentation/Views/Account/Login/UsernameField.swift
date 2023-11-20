//
//  UsernameField.swift
//  Tumble
//
//  Created by Adis Veletanlic on 2023-02-12.
//

import SwiftUI

struct UsernameField: View {
    @Binding var username: String
    
    var body: some View {
        HStack {
            Image(systemName: "person")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.onSurface.opacity(0.75))
            TextField(NSLocalizedString("Username/Email address", comment: ""), text: $username)
                .font(.system(size: 18))
                .foregroundColor(.onSurface)
                .autocapitalization(.none)
                .disableAutocorrection(true)
                .keyboardType(.emailAddress)
            Spacer()
        }
        .padding(15)
        .background(Color.surface)
        .cornerRadius(15)
        .padding(.bottom, 10)
    }
}
