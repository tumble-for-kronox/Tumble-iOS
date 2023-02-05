//
//  HomeView.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 11/16/22.
//

import Foundation

import SwiftUI
import PermissionsSwiftUINotification

struct RootView: View {
    
    @ObservedObject var viewModel: RootViewModel
    
    @Environment(\.colorScheme) var colorScheme: ColorScheme
    @AppStorage(StoreKey.overrideSystem.rawValue) private var overrideSystem = false
    @AppStorage(StoreKey.theme.rawValue) private var isDarkMode = false
    
    var body: some View {
        ZStack {
            Color.background
            switch viewModel.currentView {
            case .onboarding:
                OnBoardingView(viewModel: viewModel.onBoardingViewModel, updateUserOnBoarded: setUserOnBoarded)
            case .app:
                AppView(viewModel: viewModel.parentViewModel)
            }
        }
        //.environment(\.colorScheme, .dark)
        //.preferredColorScheme(.dark)
        .environment(\.colorScheme, isDarkMode && overrideSystem ? .dark : .light)
        .preferredColorScheme(isDarkMode ? .dark : .light)
        .ignoresSafeArea(.keyboard)
        .edgesIgnoringSafeArea(.all)
        .JMModal(showModal: $viewModel.showNotificationsPermission, for: [.notification])
    }
    
    func setUserOnBoarded() -> Void {
        self.viewModel.parentViewModel.updateViews()
        withAnimation(.linear(duration: 0.3)) {
            self.viewModel.currentView = .app
        }
    }
}
