//
//  AccountLogin.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 2023-02-12.
//

import SwiftUI

enum focusedField {
    case secure, unSecure
}

struct AccountLogin: View {
    
    @ObservedObject var viewModel: AccountViewModel
    @State private var username: String = ""
    @State private var password: String = ""
    @State private var visiblePassword: Bool = false
    
    let createToast: (ToastStyle, String, String) -> Void
    
    var body: some View {
        GeometryReader { geometry in
            VStack (spacing: 30) {
                LoginHeader()
                VStack {
                    UsernameField(username: $username)
                    PasswordField(password: $password, visiblePassword: $visiblePassword)
                }
                LoginButton(login: login, username: $username, password: $password)
                LoginSubHeader(schoolName: viewModel.school?.name ?? "")
                Spacer()
            }
            .ignoresSafeArea(.keyboard)
            .padding(.horizontal, 15)
            .padding(.top, 10)
        }
        .background(Color.background)
    }
    
    fileprivate func login() -> Void {
        viewModel.login(username: username, password: password, createToast: createToast)
    }
    
    fileprivate func createToast(success: Bool) -> Void {
        if success {
            createToast(
                .success,
                NSLocalizedString("Logged in", comment: ""),
                String(format: NSLocalizedString("Successfully logged in as %@", comment: ""), viewModel.username ?? username)
            )
        } else {
            createToast(
                .error,
                NSLocalizedString("Error", comment: ""),
                NSLocalizedString("Something went wrong when logging in to your account", comment: "")
            )
        }
    }
}
