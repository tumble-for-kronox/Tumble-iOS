//
//  RootViewModel.swift
//  Tumble
//
//  Created by Adis Veletanlic on 11/20/22.
//

import Combine
import Foundation
import SwiftUI

final class RootViewModel: ObservableObject {
    @Inject private var authManager: AuthManager
    @Inject private var preferenceService: PreferenceService
    
    var viewModelFactory: ViewModelFactory = .shared
    
    @Published var currentView: RootViewStatus = .onboarding
    @Published var userOnBoarded: Bool = false
    var parentViewModel: ParentViewModel? = nil
    var onBoardingViewModel: OnBoardingViewModel? = nil
    
    private var userOnBoardingSubscription: AnyCancellable?
    private var currentlyOnboarding: Bool = false
    
    init() { setUpDataPublishers() }
    
    func setUpDataPublishers() {
        print("HERE")
        userOnBoardingSubscription = preferenceService.$userOnBoarded
            .receive(on: RunLoop.main)
            .sink { [weak self] userOnBoarded in
                guard let self = self else { return }
                if userOnBoarded {
                    self.parentViewModel = self.viewModelFactory.makeViewModelParent()
                    if self.currentlyOnboarding {
                        withAnimation(.spring()) {
                            self.currentView = .app
                        }
                    } else {
                        self.currentView = .app
                    }
                    self.userOnBoardingSubscription?.cancel()
                } else {
                    self.currentlyOnboarding = true
                    self.onBoardingViewModel = self.viewModelFactory.makeViewModelOnBoarding()
                    self.currentView = .onboarding
                }
            }
    }
    
    func cancelSubscriptions() {
        userOnBoardingSubscription?.cancel()
    }
    
    deinit {
        cancelSubscriptions()
    }
}
