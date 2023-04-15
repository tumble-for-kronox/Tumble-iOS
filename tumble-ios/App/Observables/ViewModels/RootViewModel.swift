//
//  TabSwitcherView-ViewModel.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 11/20/22.
//

import Foundation
import SwiftUI
import Combine

@MainActor final class RootViewModel: ObservableObject {
    
    @Inject private var authManager: AuthManager
    @Inject private var preferenceService: PreferenceService
    
    var viewModelFactory: ViewModelFactory = ViewModelFactory.shared
    
    @Published var currentView: RootViewStatus = .onboarding
    @Published var userOnBoarded: Bool = false
    var parentViewModel: ParentViewModel? = nil
    var onBoardingViewModel: OnBoardingViewModel? = nil
    
    private var userOnBoardingSubscription: AnyCancellable?
    
    init() { initialisePipelines() }
    
    func initialisePipelines() -> Void {
        userOnBoardingSubscription = preferenceService.$userOnBoarded
            .sink { [weak self] userOnBoarded in
                guard let self = self else { return }
                if userOnBoarded {
                    self.parentViewModel = viewModelFactory.makeViewModelParent()
                    self.currentView = .app
                    self.userOnBoardingSubscription?.cancel()
                } else {
                    self.onBoardingViewModel = viewModelFactory.makeViewModelOnBoarding()
                    self.currentView = .onboarding
                }
            }
    }
}
