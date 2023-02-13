//
//  AccountPageView.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 2023-01-25.
//

import SwiftUI

struct AccountPage: View {
    @ObservedObject var viewModel: AccountPageViewModel
    var body: some View {
        VStack (alignment: .center) {
            switch viewModel.status {
            case .loading:
                InfoLoading(title: "Attempting to sign in")
            case .authorized:
                User(user: viewModel.authManager.user!, autoSignup: $viewModel.autoSignup)
            case .unAuthorized:
                AccountLogin(viewModel: viewModel)
            case .error:
                Text("Error occurred when signing in")
            }
        }
    }
}

