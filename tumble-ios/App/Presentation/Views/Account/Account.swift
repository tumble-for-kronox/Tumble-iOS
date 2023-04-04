//
//  AccountPageView.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 2023-01-25.
//

import SwiftUI

struct Account: View {
    
    @ObservedObject var viewModel: AccountViewModel
    
    let createToast: (ToastStyle, String, String) -> Void
    
    var body: some View {
        VStack (alignment: .center) {
            if viewModel.userAuthenticatedAndSignedIn() {
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
        .padding(.bottom, -10)
    }
}

