//
//  HomeView.swift
//  Tumble
//
//  Created by Adis Veletanlic on 11/20/22.
//

import SwiftUI
import PopupView

/// All navigation occurs from this view
struct AppParent: View {
    @ObservedObject var viewModel: ParentViewModel
    @ObservedObject var appController: AppController = .shared
    
    private let navigationBarAppearance = UINavigationBar.appearance()
    
    init(viewModel: ParentViewModel) {
        navigationBarAppearance.titleTextAttributes = [.font: navigationBarFont()]
        navigationBarAppearance.titleTextAttributes = [.foregroundColor: UIColor(named: "OnSurface")!]
        self.viewModel = viewModel
        
        let barAppearance = UIBarAppearance()
        let tabBarAppearance = UITabBar.appearance()
        barAppearance.configureWithDefaultBackground()
        tabBarAppearance.scrollEdgeAppearance = .init(barAppearance: barAppearance)
    }
    
    var body: some View {
        TabView(selection: $appController.selectedAppTab) {
            Home(
                viewModel: viewModel.homeViewModel,
                parentViewModel: viewModel)
            
            Bookmarks(
                viewModel: viewModel.bookmarksViewModel,
                parentViewModel: viewModel)
            
            Search(viewModel: viewModel.searchViewModel)
            
            Account(viewModel: viewModel.accountPageViewModel)
        }
        .ignoresSafeArea(.keyboard)
        .fullScreenCover(isPresented: $viewModel.userNotOnBoarded, content: {
            OnBoarding(finishOnBoarding: viewModel.finishOnboarding)
        })
        .popup(isPresented: $appController.showPopup) {
            if let popup = appController.popup {
                PopupContainer(popup: popup)
            }
        } customize: {
            $0
                .type(.floater())
                .position(.top)
                .animation(.spring())
                .closeOnTapOutside(true)
                .backgroundColor(.black.opacity(0.5))
                .autohideIn(5)
        }
    }
}

