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
            .padding(.horizontal, 15)
            .padding(.top, 20)
            .background(Color(UIColor.systemBackground))
            .frame(width: geometry.size.width, height: geometry.size.height) // Set the frame size to match the screen size
        }
        .ignoresSafeArea(.keyboard)
    }
    
    fileprivate func login() -> Void {
        viewModel.login(username: username, password: password, createToast: createToast)
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
