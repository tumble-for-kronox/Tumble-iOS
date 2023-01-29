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
        let onBoardingViewModel: OnBoardingView.OnBoardingViewModel = ViewModelFactory().makeViewModelOnBoarding()
        
        
        init (userNotOnBoarded: Bool) {
            self.userNotOnBoarded = userNotOnBoarded
        }
    }
}
