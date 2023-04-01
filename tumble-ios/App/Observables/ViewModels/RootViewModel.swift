//
//  TabSwitcherView-ViewModel.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 11/20/22.
//

import Foundation
import SwiftUI

@MainActor final class RootViewModel: ObservableObject {
    
    @Inject private var authManager: AuthManager
    
    var viewModelFactory: ViewModelFactory = ViewModelFactory.shared
    
    @Published var currentView: RootViewStatus
    var parentViewModel: ParentViewModel? = nil
    var onBoardingViewModel: OnBoardingViewModel? = nil
    
    
    init (userNotOnBoarded: Bool) {
        if userNotOnBoarded {
            self.onBoardingViewModel = viewModelFactory.makeViewModelOnBoarding()
            self.currentView = .onboarding
        } else {
            self.parentViewModel = viewModelFactory.makeViewModelParent()
            self.currentView = .app
        }
    }
    
    func delegateToAppParent() -> Void {
        self.parentViewModel = viewModelFactory.makeViewModelParent()
        if let parentViewModel = self.parentViewModel {
            parentViewModel.updateLocalsAndChildViews()
        }
        withAnimation(.linear(duration: 0.2)) {
            self.currentView = .app
        }
    }
}
