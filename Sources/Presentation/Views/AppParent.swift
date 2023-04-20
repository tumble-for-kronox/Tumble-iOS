//
//  HomeView.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 11/20/22.
//

import SwiftUI

// All navigation occurs from this view
struct AppParent: View {
    @ObservedObject var viewModel: ParentViewModel
    @ObservedObject var appController: AppController = .shared
        
    private let navigationBarAppearance = UINavigationBar.appearance()
    
    init(viewModel: ParentViewModel) {
        navigationBarAppearance.titleTextAttributes = [.font: navigationBarFont()]
        navigationBarAppearance.titleTextAttributes = [.foregroundColor: UIColor(named: "OnSurface")!]
        self.viewModel = viewModel
    }
    
    var body: some View {
        NavigationView {
            VStack {
                // Main home page view switcher
                switch appController.selectedAppTab {
                case .home:
                    Home(
                        viewModel: viewModel.homeViewModel,
                        parentViewModel: viewModel,
                        selectedAppTab: $appController.selectedAppTab
                    )
                case .bookmarks:
                    Bookmarks(
                        viewModel: viewModel.bookmarksViewModel,
                        parentViewModel: viewModel
                    )
                case .account:
                    Account(viewModel: viewModel.accountPageViewModel)
                }
                TabBar(selectedAppTab: $appController.selectedAppTab)
            }
            .ignoresSafeArea(.keyboard)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing, content: {
                    NavigationbarSearch(
                        viewModel: viewModel.searchViewModel)
                })
                ToolbarItem(placement: .navigationBarTrailing, content: {
                    NavigationbarSettings(
                        viewModel: viewModel.settingsViewModel)
                })
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle(NSLocalizedString(appController.selectedAppTab.displayName, comment: ""))
        }
        .tint(.primary)
        .offset(x: appController.showSideBar ? getRect().width - 120 : 0)
        .toastView(toast: $appController.toast)
        .ignoresSafeArea(.keyboard)
        .navigationViewStyle(StackNavigationViewStyle())
        .zIndex(1)
        .ignoresSafeArea(.keyboard)
    }
}
