//
//  AccountPageView.swift
//  Tumble
//
//  Created by Adis Veletanlic on 2023-01-25.
//

import SwiftUI

struct Account: View {
    @ObservedObject var viewModel: AccountViewModel
    @ObservedObject var appController: AppController = .shared
        
    var body: some View {
        NavigationView {
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
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle(NSLocalizedString("Account", comment: ""))
            .navigationBarItems(trailing: HStack {
                if viewModel.status == .authenticated {
                    SignOutButton(signOut: {
                        Task {
                            await viewModel.logOut()
                        }
                    })
                }
                SettingsButton()
            })
            
        }
        .tabItem {
            TabItem(appTab: TabbarTabType.account, selectedAppTab: $appController.selectedAppTab)
        }
        .tag(TabbarTabType.account)
    }
}
