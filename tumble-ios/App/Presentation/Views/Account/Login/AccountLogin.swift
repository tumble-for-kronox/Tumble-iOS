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
    
    @ObservedObject var viewModel: AccountPageViewModel
    @EnvironmentObject var userModel: UserController
    
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
                viewModel.status = .loading
                userModel.logIn(username: username, password: password, completion: { success in
                    if success {
                        createToast(.success, "Logged in", "Successfully logged in as \(userModel.user?.username ?? username)")
                    } else {
                        createToast(.error, "Error", "Something went wrong when logging in ...")
                    }
                    viewModel.status = .initial
                })
            })
            LoginSubHeader(schoolName: viewModel.school?.name ?? "")
        }
        .padding(.horizontal, 15)
        .padding(.top, 20)
    }
}
