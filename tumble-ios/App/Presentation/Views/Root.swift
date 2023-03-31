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
    @AppStorage(StoreKey.appearance.rawValue) private var appearance = AppearanceTypes.system.rawValue
    
    init(viewModel: RootViewModel) {
        self.viewModel = viewModel
        UserDefaults.standard.set("sv", forKey: "AppleLanguage")
    }
    
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
        .preferredColorScheme(getThemeColorScheme())
        .edgesIgnoringSafeArea(.all)
        .ignoresSafeArea(.keyboard)
        .JMAlert(showModal: $viewModel.showNotificationsPermission, for: [.notification])
    }
    
    func setUserOnBoarded() -> Void {
        self.viewModel.parentViewModel.updateLocalsAndChildViews()
        withAnimation(.linear(duration: 0.2)) {
            self.viewModel.currentView = .app
        }
    }
    
    private func getThemeColorScheme() -> ColorScheme {
        switch appearance {
        case AppearanceTypes.dark.rawValue:
            return .dark
        case AppearanceTypes.light.rawValue:
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

