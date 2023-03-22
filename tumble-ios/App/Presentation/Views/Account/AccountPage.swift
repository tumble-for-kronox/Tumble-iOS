//
//  AccountPageView.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 2023-01-25.
//

import SwiftUI

struct AccountPage: View {
    
    @ObservedObject var viewModel: AccountViewModel
    
    let createToast: (ToastStyle, String, String) -> Void
    
    var body: some View {
        VStack (alignment: .center) {
            if viewModel.userController.authStatus == .authorized || viewModel.userController.refreshToken != nil {
                UserOverview(viewModel: viewModel, schoolName: viewModel.school?.name ?? "", createToast: createToast)
            } else {
                if viewModel.status == .loading {
                    InfoLoading(title: "Attempting to log in user")
                } else if viewModel.status == .initial {
                    AccountLogin(viewModel: viewModel, createToast: createToast)
                }
            }
        }
        .background(Color.background)
        .padding(.bottom, -10)
    }
    
}

