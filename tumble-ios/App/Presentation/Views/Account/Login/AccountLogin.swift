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
    
    @State private var username: String = ""
    @State private var password: String = ""
    @State private var visiblePassword: Bool = false
    
    var body: some View {
        VStack (spacing: 30) {
            LoginHeader()
            VStack {
                UsernameField(username: $username)
                PasswordField(password: $password, visiblePassword: $visiblePassword)
            }
            .padding(.horizontal, 35)
            LoginButton(login: {
                viewModel.login(username: username, password: password)
            })
            LoginSubHeader(schoolName: viewModel.school?.name ?? "")
        }
        .padding(.top, 50)
    }
}


struct AccountLogin_Previews: PreviewProvider {
    static var previews: some View {
        AccountLogin(viewModel: ViewModelFactory().makeViewModelAccountPage())
    }
}
