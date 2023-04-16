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
    
    func makeViewModelParent() -> ParentViewModel { .init() }

    func makeViewModelSearch() -> SearchViewModel { .init() }
    
    func makeViewModelHome() -> HomeViewModel { .init() }
    
    func makeViewModelBookmarks() -> BookmarksViewModel { .init() }
    
    func makeViewModelAccount() -> AccountViewModel { .init() }
    
    func makeViewModelResource() -> ResourceViewModel { .init() }
    
    func makeViewModelOnBoarding() -> OnBoardingViewModel { .init() }
    
    func makeViewModelSettings() -> SettingsViewModel { .init() }
    
    // Special viewmodel important for checking user onboarding in order to change
    // the displayed child view
    func makeViewModelRoot() -> RootViewModel { .init() }
    
    // Viewmodels requiring parameters during creation
    func makeViewModelEventDetailsSheet(
        event: Response.Event,
        color: Color) -> EventDetailsSheetViewModel {
            .init(event: event, color: color)
    }
    
    func makeViewModelSearchPreview(
        scheduleId: String) -> SearchPreviewViewModel { .init(scheduleId: scheduleId) }
}
