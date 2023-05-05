//
//  HomeView.swift
//  Tumble
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
            ZStack {
                Color.background.ignoresSafeArea(.all)
                TabView(selection: $appController.selectedAppTab, content: {
                    Home(
                        viewModel: viewModel.homeViewModel,
                        parentViewModel: viewModel,
                        selectedAppTab: $appController.selectedAppTab
                    )
                    .tabItem {
                        TabItem(appTab: TabbarTabType.home)
                    }
                    .tag(TabbarTabType.home)
                    Bookmarks(
                        viewModel: viewModel.bookmarksViewModel,
                        parentViewModel: viewModel
                    )
                    .tabItem {
                        TabItem(appTab: TabbarTabType.bookmarks)
                    }
                    .tag(TabbarTabType.bookmarks)
                    Account(viewModel: viewModel.accountPageViewModel)
                        .tabItem {
                            TabItem(appTab: TabbarTabType.account)
                        }
                        .tag(TabbarTabType.account)
                })
                .tabViewStyle(.automatic)
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
        .toastView(toast: $appController.toast)
        .ignoresSafeArea(.keyboard)
        .navigationViewStyle(StackNavigationViewStyle())
        .zIndex(1)
        .ignoresSafeArea(.keyboard)
    }
}
