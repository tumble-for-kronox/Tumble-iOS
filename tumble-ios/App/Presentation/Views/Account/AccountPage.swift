//
//  AccountPageView.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 2023-01-25.
//

import SwiftUI

struct AccountPage: View {
    
    @ObservedObject var viewModel: AccountPageViewModel
    @EnvironmentObject private var userModel: UserController
    
    let createToast: (ToastStyle, String, String) -> Void
    
    var body: some View {
        VStack (alignment: .center) {
            if userModel.authStatus == .authorized || userModel.refreshToken != nil {
                UserOverview(viewModel: viewModel, userImage: $userModel.profilePicture, name: userModel.user!.name, username: userModel.user!.username, schoolName: viewModel.school?.name ?? "", createToast: createToast, toggleAutoSignup: toggleAutoSignup, updateUserImage: updateUserImage, autoSignup: $viewModel.autoSignup)
                    .environmentObject(userModel)
            } else {
                if viewModel.status == .loading {
                    InfoLoading(title: "Attempting to log in user")
                } else if viewModel.status == .initial {
                    AccountLogin(viewModel: viewModel, createToast: createToast)
                }
            }
        }
    }
    
    fileprivate func toggleAutoSignup(value: Bool) -> Void {
        viewModel.toggleAutoSignup(value: value)
    }
    
    fileprivate func updateUserImage(image: UIImage) -> Void {
        userModel.profilePicture = image
    }
    
}

