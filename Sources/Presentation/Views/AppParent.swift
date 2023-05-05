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
        TabView(selection: $appController.selectedAppTab) {
            NavigationView {
                Home(
                    viewModel: viewModel.homeViewModel,
                    parentViewModel: viewModel,
                    selectedAppTab: $appController.selectedAppTab
                )
                .navigationBarTitleDisplayMode(.inline)
                .navigationTitle(NSLocalizedString("Home", comment: ""))
                .navigationBarItems(trailing: HStack {
                    NavigationbarSearch(
                        viewModel: viewModel.searchViewModel
                    )
                })
            }
            .tabItem {
                TabItem(appTab: TabbarTabType.home)
            }
            .tag(TabbarTabType.home)
            
            NavigationView {
                Bookmarks(
                    viewModel: viewModel.bookmarksViewModel,
                    parentViewModel: viewModel
                )
                .navigationBarTitleDisplayMode(.inline)
                .navigationBarTitle(NSLocalizedString("Bookmarks", comment: ""))
            }
            .tabItem {
                TabItem(appTab: TabbarTabType.bookmarks)
            }
            .tag(TabbarTabType.bookmarks)
            
            NavigationView {
                Account(viewModel: viewModel.accountPageViewModel)
                    .navigationBarTitleDisplayMode(.inline)
                    .navigationTitle(NSLocalizedString("Account", comment: ""))
                    .navigationBarItems(trailing: HStack {
                        NavigationbarSettings(
                            viewModel: viewModel.settingsViewModel
                        )
                    })
            }
            .tabItem {
                TabItem(appTab: TabbarTabType.account)
            }
            .tag(TabbarTabType.account)
        }
        .tint(.primary)
        .toastView(toast: $appController.toast)
        .ignoresSafeArea(.keyboard)
        .navigationViewStyle(StackNavigationViewStyle())
        .zIndex(1)
    }
}

