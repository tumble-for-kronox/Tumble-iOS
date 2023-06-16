//
//  PasswordField.swift
//  Tumble
//
//  Created by Adis Veletanlic on 2023-02-12.
//

import SwiftUI

struct PasswordField: View {
    @Binding var password: String
    @FocusState var focused: FocusedField?
    @Binding var visiblePassword: Bool
    
    var body: some View {
        HStack {
            Image(systemName: "lock")
                .foregroundColor(.onSurface.opacity(0.75))
            ZStack {
                TextField(NSLocalizedString("Password", comment: ""), text: $password)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                    .focused($focused, equals: .unSecure)
                    .keyboardType(.alphabet)
                    .foregroundColor(.onSurface)
                    .opacity(visiblePassword ? 1 : 0)
                SecureField(NSLocalizedString("Password", comment: ""), text: $password)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                    .focused($focused, equals: .secure)
                    .foregroundColor(.onSurface)
                    .opacity(visiblePassword ? 0 : 1)
            }
            Button(action: {
                visiblePassword.toggle()
                focused = focused == .unSecure ? .unSecure : .secure
            }) {
                Image(systemName: visiblePassword ? "eye" : "eye.slash")
                    .foregroundColor(.onSurface.opacity(0.75))
            }
            Spacer()
        }
        .padding(15)
        .background(Color.surface)
        .cornerRadius(15)
    }
}
