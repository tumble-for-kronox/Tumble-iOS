//
//  HomeView.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 11/16/22.
//

import SwiftUI

struct Root: View {
    
    @ObservedObject var viewModel: RootViewModel
    @AppStorage(StoreKey.appearance.rawValue) private var appearance = AppearanceTypes.system.rawValue
    
    var body: some View {
        ZStack {
            switch viewModel.currentView {
            case .onboarding:
                if let onBoardingViewModel = viewModel.onBoardingViewModel {
                    OnBoarding(viewModel: onBoardingViewModel, updateUserOnBoarded: setUserOnBoarded)
                }
            case .app:
                if let parentViewModel = viewModel.parentViewModel {
                    AppParent(viewModel: parentViewModel)
                        .environmentObject(AppController.shared)
                }
            }
        }
        .colorScheme(getThemeColorScheme())
        .preferredColorScheme(getThemeColorScheme())
        .edgesIgnoringSafeArea(.all)
        .ignoresSafeArea(.keyboard)
    }
    
    func setUserOnBoarded() -> Void {
        self.viewModel.delegateToAppParent()
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

