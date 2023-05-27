//
//  AccountPageView.swift
//  Tumble
//
//  Created by Adis Veletanlic on 2023-01-25.
//

import SwiftUI

struct Account: View {
    @ObservedObject var viewModel: AccountViewModel
        
    var body: some View {
        VStack(alignment: .center) {
            switch viewModel.status {
            case .authenticated:
                UserOverview(viewModel: viewModel)
            case .unAuthenticated:
                AccountLogin(viewModel: viewModel)
            case .loading:
                InfoLoading(title: NSLocalizedString("Attempting to log in user", comment: ""))
            case .error:
                Info(title: NSLocalizedString("Something went wrong", comment: ""), image: nil)
            }
        }
        .frame(maxHeight: .infinity)
        .ignoresSafeArea(.keyboard)
        .padding(.bottom, -10)
    }
}
