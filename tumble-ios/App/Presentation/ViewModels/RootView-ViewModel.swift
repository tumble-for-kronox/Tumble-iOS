//
//  TabSwitcherView-ViewModel.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 11/20/22.
//

import Foundation

enum RootViewStatus {
    case onboarding
    case app
}

extension RootView {
    @MainActor final class RootViewModel: ObservableObject {
        
        @Published var currentView: RootViewStatus
        let appViewModel: MainAppView.MainAppViewModel = ViewModelFactory().makeViewModelApp()
        let onBoardingViewModel: OnBoardingView.OnBoardingViewModel = ViewModelFactory().makeViewModelOnBoarding()
        
        
        init (userNotOnBoarded: Bool) {
            self.currentView = userNotOnBoarded ? .onboarding : .app
        }
    }
}
