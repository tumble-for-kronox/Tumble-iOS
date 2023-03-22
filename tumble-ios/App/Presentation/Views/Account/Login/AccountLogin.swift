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
        VStack (spacing: 30) {
            LoginHeader()
            VStack {
                UsernameField(username: $username)
                PasswordField(password: $password, visiblePassword: $visiblePassword)
            }
            LoginButton(login: {
                viewModel.login(username: username, password: password, createToast: createToast)
            })
            LoginSubHeader(schoolName: viewModel.school?.name ?? "")
            Spacer()
        }
        .padding(.horizontal, 15)
        .padding(.top, 20)
        .background(Color.background)
    }
    
    fileprivate func createToast(success: Bool) -> Void {
        if success {
            createToast(
                .success,
                "Logged in",
                "Successfully logged in as \(viewModel.userController.user?.username ?? username)"
            )
        } else {
            createToast(
                .error,
                "Error",
                "Something went wrong when logging in to your account"
            )
        }
    }
}
