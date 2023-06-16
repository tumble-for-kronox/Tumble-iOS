//
//  AccountLogin.swift
//  Tumble
//
//  Created by Adis Veletanlic on 2023-02-12.
//

import SwiftUI

enum FocusedField {
    case secure, unSecure
}

struct AccountLogin: View {
    @ObservedObject var viewModel: LoginViewModel = .init()
    @ObservedObject var appController: AppController = .shared
    
    @State private var username: String = ""
    @State private var password: String = ""
    @State private var visiblePassword: Bool = false
    @State private var selectedSchool: School? = nil
    
    var body: some View {
        GeometryReader { _ in
            VStack {
                LoginHeader()
                VStack {
                    HStack {
                        Spacer()
                        schoolSelectionMenu
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.bottom, 20)
                    VStack {
                        UsernameField(username: $username)
                        PasswordField(password: $password, visiblePassword: $visiblePassword)
                    }
                }
                if viewModel.attemptingLogin {
                    CustomProgressIndicator()
                        .padding(.top, 35)
                } else {
                    LoginButton(login: login, username: $username, password: $password)
                }
                Spacer()
            }
            .ignoresSafeArea(.keyboard)
            .padding(.horizontal, 20)
            .padding(.top, 35)
            .frame(alignment: .center)
        }
        .background(Color.background)
    }
    
    var schoolSelectionMenu: some View {
        Menu {
            ForEach(viewModel.schools, id: \.self) { school in
                Button(action: {
                    selectedSchool = school
                    setSchoolForAuth()
                }, label: {
                    HStack {
                        Text(school.name)
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(.onBackground)
                        if school == selectedSchool {
                            Image(systemName: "checkmark")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.onBackground)
                        }
                    }
                })
            }
        } label: {
            HStack {
                Image(systemName: "chevron.up.chevron.down")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.primary)
                Text(selectedSchool?.name ?? NSLocalizedString("Select university", comment: ""))
                    .font(.system(size: 16, weight: .semibold))
            }
        }
    }
    
    fileprivate func login() {
        if let selectedSchool = selectedSchool {
            Task {
                await viewModel.login(
                    authSchoolId: selectedSchool.id,
                    username: username,
                    password: password
                )
            }
        } else { /// No school selected, invalid
            AppController.shared.popup = PopupFactory.shared.loginRequiresSchool()
        }
    }
    
    fileprivate func setSchoolForAuth() {
        if let selectedSchool = selectedSchool {
            viewModel.setDefaultAuthSchool(schoolId: selectedSchool.id)
        }
    }
}
