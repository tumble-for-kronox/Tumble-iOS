//
//  TabSwitcherView-ViewModel.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 11/20/22.
//

import Foundation

extension RootView {
    @MainActor final class RootViewModel: ObservableObject {

        @Published var userNotOnBoarded: Bool
        let appViewModel: MainAppView.MainAppViewModel = ViewModelFactory().makeViewModelApp()
        let onBoardingViewModel: OnBoardingMainView.OnBoardingViewModel = ViewModelFactory().makeViewModelOnBoarding()
        
        
        init (userNotOnBoarded: Bool) {
            print("User not onboarded: \(userNotOnBoarded)")
            self.userNotOnBoarded = userNotOnBoarded
        }
    }
}
