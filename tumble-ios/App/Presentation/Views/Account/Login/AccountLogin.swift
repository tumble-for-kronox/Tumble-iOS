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
    
    @ObservedObject var viewModel: AccountPage.AccountPageViewModel
    @EnvironmentObject var userModel: UserModel
    
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
            .padding(.horizontal, 35)
            LoginButton(login: {
                userModel.logIn(username: username, password: password, completion: { success in
                    if success {
                        createToast(.success, "Logged in", "Successfully logged in as \(userModel.user?.username ?? username)")
                    } else {
                        createToast(.error, "Error", "Something went wrong when logging in ...")
                    }
                })
            })
            LoginSubHeader(schoolName: viewModel.school?.name ?? "")
        }
        .padding(.top, 50)
    }
}
