//
//  ViewModelFactory.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 2023-01-27.
//

import Foundation
import SwiftUI

class ViewModelFactory {
    
    static let shared = ViewModelFactory()
    
    @Inject var preferenceService: PreferenceService
    
    @MainActor func makeViewModelParent() -> ParentViewModel { .init() }

    @MainActor func makeViewModelSearch() -> SearchViewModel { .init() }
    
    @MainActor func makeViewModelHome() -> HomeViewModel { .init() }
    
    @MainActor func makeViewModelBookmarks() -> BookmarksViewModel { .init() }
    
    @MainActor func makeViewModelAccount() -> AccountViewModel { .init() }
    
    @MainActor func makeViewModelResource() -> ResourceViewModel { .init() }
    
    @MainActor func makeViewModelOnBoarding() -> OnBoardingViewModel { .init() }
    
    // Special viewmodel important for checking user onboarding in order to change
    // the displayed child view
    @MainActor func makeViewModelRoot() -> RootViewModel {
            .init(
                userNotOnBoarded: !preferenceService.isKeyPresentInUserDefaults(
                    key: StoreKey.userOnboarded.rawValue
                )
            )
        }
    // Isolated viewmodel requiring an event and color
    @MainActor func makeViewModelEventDetailsSheet(
        event: Response.Event,
        color: Color) -> EventDetailsSheetViewModel {
            .init(event: event, color: color)
    }
    
    @MainActor func makeViewModelSettings() -> SettingsViewModel { .init() }
}
