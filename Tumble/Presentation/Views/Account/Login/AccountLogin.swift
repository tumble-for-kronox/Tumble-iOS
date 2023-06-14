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
    @ObservedObject var viewModel: AccountViewModel
    @ObservedObject var appController: AppController = .shared
    
    @State private var username: String = ""
    @State private var password: String = ""
    @State private var visiblePassword: Bool = false
    @State private var selectedSchool: School? = nil
    @State private var blurSelection: Bool = true
        
    var body: some View {
        GeometryReader { _ in
            VStack(spacing: 30) {
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
    
    var schoolSelectionMenu: some View {
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
        }
    }
    
    fileprivate func setSchoolForAuth() {
        if let selectedSchool = selectedSchool {
            viewModel.setDefaultAuthSchool(schoolId: selectedSchool.id)
        }
    }
}
