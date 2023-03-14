//
//  HomeView.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 11/16/22.
//

import Foundation

import SwiftUI
import PermissionsSwiftUINotification

struct Root: View {
    
    @ObservedObject var viewModel: RootViewModel
    
    @Environment(\.colorScheme) var colorScheme: ColorScheme
    @AppStorage(StoreKey.overrideSystemTheme.rawValue) private var overrideSystem = false
    @AppStorage(StoreKey.theme.rawValue) private var isDarkMode = false
    
    var body: some View {
        ZStack {
            Color.background
            switch viewModel.currentView {
            case .onboarding:
                OnBoarding(viewModel: viewModel.onBoardingViewModel, updateUserOnBoarded: setUserOnBoarded)
            case .app:
                AppParent(viewModel: viewModel.parentViewModel)
                    .environmentObject(AppController.shared)
            }
        }
        .environment(\.colorScheme, colorScheme)
        .edgesIgnoringSafeArea(.all)
        .JMModal(showModal: $viewModel.showNotificationsPermission, for: [.notification])
    }
    
    func setUserOnBoarded() -> Void {
        self.viewModel.parentViewModel.updateLocalsAndChildViews()
        withAnimation(.linear(duration: 0.2)) {
            self.viewModel.currentView = .app
        }
    }
}
