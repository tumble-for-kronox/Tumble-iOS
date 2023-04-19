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
    @State private var selectedSchool: School? = nil
    @State private var blurSelection: Bool = true
        
    var body: some View {
        GeometryReader { geometry in
            VStack (spacing: 30) {
                LoginHeader()
                VStack {
                    HStack {
                        Spacer()
                        Menu {
                            ForEach(viewModel.schoolManager.getSchools(), id: \.self) { school in
                                Button(action: {
                                    selectedSchool = school
                                    setSchoolForAuth()
                                    withAnimation(.easeIn) {
                                        blurSelection = false
                                    }
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
                                Image(systemName: "plus")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(.primary)
                                Text(selectedSchool?.name ?? NSLocalizedString("Select university", comment: ""))
                                    .font(.system(size: 16, weight: .semibold))
                            }
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.bottom, 20)
                    VStack {
                        UsernameField(username: $username)
                        PasswordField(password: $password, visiblePassword: $visiblePassword)
                    }
                    .disabled(blurSelection)
                    .blur(radius: blurSelection ? 2.5 : 0)
                }
                LoginButton(login: login, username: $username, password: $password)
                    .disabled(blurSelection)
                    .blur(radius: blurSelection ? 2.5 : 0)
                Spacer()
            }
            .ignoresSafeArea(.keyboard)
            .padding(.horizontal, 20)
            .padding(.top, 10)
        }
        .background(Color.background)
    }
    
    fileprivate func login() -> Void {
        if let selectedSchool = selectedSchool {
            viewModel.login(
                authSchoolId: selectedSchool.id,
                username: username,
                password: password,
                createToast: createToast)
        }
    }
    
    fileprivate func setSchoolForAuth() -> Void {
        if let selectedSchool = selectedSchool {
            viewModel.setDefaultAuthSchool(schoolId: selectedSchool.id)
        }
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
