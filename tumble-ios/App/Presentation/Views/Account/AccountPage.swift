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
            if userAuthenticatedAndSignedIn() {
                UserOverview(viewModel: viewModel, schoolName: viewModel.school?.name ?? "", createToast: createToast)
            } else {
                if viewModel.status == .loading {
                    InfoLoading(title: NSLocalizedString("Attempting to log in user", comment: ""))
                } else if viewModel.status == .initial {
                    AccountLogin(viewModel: viewModel, createToast: createToast)
                }
            }
        }
        .frame(maxHeight: .infinity)
        .ignoresSafeArea(.keyboard)
        .background(Color(UIColor.systemBackground))
        .padding(.bottom, -10)
    }
    
    fileprivate func userAuthenticatedAndSignedIn() -> Bool {
        return viewModel.userController.authStatus == .authorized || viewModel.userController.refreshToken != nil
    }
    
}

