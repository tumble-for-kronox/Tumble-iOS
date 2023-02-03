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
        
        let viewModelFactory: ViewModelFactory = ViewModelFactory.shared
        
        @Published var currentView: RootViewStatus
        let appViewModel: MainAppView.MainAppViewModel
        let onBoardingViewModel: OnBoardingView.OnBoardingViewModel
        
        init (userNotOnBoarded: Bool) {
            
            self.appViewModel = viewModelFactory.makeViewModelApp()
            self.onBoardingViewModel = viewModelFactory.makeViewModelOnBoarding()
            
            self.currentView = userNotOnBoarded ? .onboarding : .app
        }
    }
}