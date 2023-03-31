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

@MainActor final class RootViewModel: ObservableObject {
    
    @Inject private var authManager: AuthManager
    
    let viewModelFactory: ViewModelFactory = ViewModelFactory.shared
    
    @Published var currentView: RootViewStatus
    @Published var showNotificationsPermission: Bool
    let parentViewModel: ParentViewModel
    let onBoardingViewModel: OnBoardingViewModel
    
    
    init (userNotOnBoarded: Bool) {
        self.parentViewModel = viewModelFactory.makeViewModelParent()
        self.onBoardingViewModel = viewModelFactory.makeViewModelOnBoarding()
        self.currentView = userNotOnBoarded ? .onboarding : .app
        self.showNotificationsPermission = userNotOnBoarded ? true : false
    }
}
