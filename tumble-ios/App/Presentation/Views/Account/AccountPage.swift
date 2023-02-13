//
//  AccountPageView.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 2023-01-25.
//

import SwiftUI

struct AccountPage: View {
    
    @ObservedObject var viewModel: AccountPageViewModel
    @EnvironmentObject private var userModel: UserModel
    
    let createToast: (ToastStyle, String, String) -> Void
    
    var body: some View {
        VStack (alignment: .center) {
            if userModel.authStatus == .authorized {
                User(user: userModel.user!, toggleAutoSignup: toggleAutoSignup, userBookings: viewModel.userBookings, autoSignup: $viewModel.autoSignup)
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
    
}

