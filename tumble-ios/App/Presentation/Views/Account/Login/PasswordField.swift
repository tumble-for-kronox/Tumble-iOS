//
//  PasswordField.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 2023-02-12.
//

import SwiftUI

struct PasswordField: View {
    
    @Binding var password: String
    @FocusState var focused: focusedField?
    @Binding var visiblePassword: Bool
    
    var body: some View {
        HStack {
            Image(systemName: "lock")
                .foregroundColor(.onBackground.opacity(0.75))
            ZStack {
                TextField("Password", text: $password)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                    .focused($focused, equals: .unSecure)
                    .keyboardType(.alphabet)
                    .foregroundColor(.onBackground)
                    .opacity(visiblePassword ? 1 : 0)
                SecureField("Password", text: $password)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                    .focused($focused, equals: .secure)
                    .foregroundColor(.onBackground)
                    .opacity(visiblePassword ? 0 : 1)
            }
            Button(action: {
                visiblePassword.toggle()
                focused = focused == .secure ? .unSecure : .secure
            }) {
                Image(systemName: visiblePassword ? "eye" : "eye.slash")
                    .foregroundColor(.onBackground.opacity(0.75))
            }
            Spacer()
        }
        .padding(10)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(lineWidth: 0.5)
                .foregroundColor(.onBackground.opacity(0.5)
            )
        )
    }
}


