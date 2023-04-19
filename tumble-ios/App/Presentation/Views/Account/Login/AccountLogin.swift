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
    @ObservedObject var appController: AppController = AppController.shared
    
    @State private var username: String = ""
    @State private var password: String = ""
    @State private var visiblePassword: Bool = false
        
    var body: some View {
        GeometryReader { geometry in
            VStack (spacing: 30) {
                LoginHeader()
                VStack {
                    UsernameField(username: $username)
                    PasswordField(password: $password, visiblePassword: $visiblePassword)
                }
                LoginButton(login: login, username: $username, password: $password)
                LoginSubHeader(schoolName: viewModel.schoolName)
                Spacer()
            }
            .ignoresSafeArea(.keyboard)
            .padding(.horizontal, 20)
            .padding(.top, 10)
        }
        .background(Color.background)
    }
    
    fileprivate func login() -> Void {
        viewModel.login(username: username, password: password, createToast: createToast)
    }
    
    fileprivate func createToast(success: Bool) -> Void {
        if success {
            appController.toast = Toast(
                type: .success,
                title: NSLocalizedString("Logged in", comment: ""),
                message: String(format: NSLocalizedString("Successfully logged in as %@", comment: ""), viewModel.username ?? username)
            )
        } else {
            appController.toast = Toast(
                type: .error,
                title: NSLocalizedString("Error", comment: ""),
                message: NSLocalizedString("Something went wrong when logging in to your account", comment: "")
            )
        }
    }
}
