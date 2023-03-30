//
//  HomeView.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 11/16/22.
//

import SwiftUI
import PermissionsSwiftUINotification

struct Root: View {
    
    @ObservedObject var viewModel: RootViewModel
    
    @AppStorage(StoreKey.appearance.rawValue) private var appearance = AppearanceType.system.rawValue
    
    var body: some View {
        ZStack {
            Color(UIColor.systemBackground)
            switch viewModel.currentView {
            case .onboarding:
                OnBoarding(viewModel: viewModel.onBoardingViewModel, updateUserOnBoarded: setUserOnBoarded)
            case .app:
                AppParent(viewModel: viewModel.parentViewModel)
                    .environmentObject(AppController.shared)
            }
        }
        .colorScheme(getThemeColorScheme())
        .edgesIgnoringSafeArea(.all)
        .ignoresSafeArea(.keyboard)
        .JMModal(showModal: $viewModel.showNotificationsPermission, for: [.notification])
    }
    
    func setUserOnBoarded() -> Void {
        self.viewModel.parentViewModel.updateLocalsAndChildViews()
        withAnimation(.linear(duration: 0.2)) {
            self.viewModel.currentView = .app
        }
    }
    
    private func getThemeColorScheme() -> ColorScheme {
        switch appearance {
        case AppearanceType.dark.rawValue:
            return .dark
        case AppearanceType.light.rawValue:
            return .light
        default:
            if UITraitCollection.current.userInterfaceStyle == .dark {
                return .dark
            } else {
                return .light
            }
        }
    }
}

