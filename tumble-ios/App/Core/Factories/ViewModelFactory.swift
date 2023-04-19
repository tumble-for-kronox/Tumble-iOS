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
        
    func makeViewModelParent() -> ParentViewModel { .init() }

    func makeViewModelSearch() -> SearchViewModel { .init() }
    
    func makeViewModelHome() -> HomeViewModel { .init() }
    
    func makeViewModelBookmarks() -> BookmarksViewModel { .init() }
    
    func makeViewModelAccount() -> AccountViewModel { .init() }
    
    func makeViewModelResource() -> ResourceViewModel { .init() }
    
    func makeViewModelOnBoarding() -> OnBoardingViewModel { .init() }
    
    func makeViewModelSettings() -> SettingsViewModel { .init() }
    
    func makeViewModelRoot() -> RootViewModel { .init() }
    
    func makeViewModelEventDetailsSheet(
        event: Event) -> EventDetailsSheetViewModel {
            .init(event: event)
    }
    
    func makeViewModelSearchPreview(
        scheduleId: String) -> SearchPreviewViewModel { .init(scheduleId: scheduleId) }
}
