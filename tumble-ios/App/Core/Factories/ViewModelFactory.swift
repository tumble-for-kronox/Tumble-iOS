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

    @MainActor func makeViewModelSearch() -> SearchPage.SearchPageViewModel { .init() }
    
    @MainActor func makeViewModelHomePage() -> HomePage.HomePageViewModel { .init() }
    
    @MainActor func makeViewModelBookmarks() -> BookmarkPage.BookmarkPageViewModel { .init() }
    
    @MainActor func makeViewModelAccountPage() -> AccountPage.AccountPageViewModel { .init() }
    
    @MainActor func makeViewModelOnBoarding() -> OnBoarding.OnBoardingViewModel { .init() }
    
    // Special viewmodel important for checking user onboarding in order to change
    // the displayed child view
    @MainActor func makeViewModelRoot() -> Root.RootViewModel {
            .init(
                userNotOnBoarded: !preferenceService.isKeyPresentInUserDefaults(key: StoreKey.userOnboarded.rawValue))
        }
    // Isolated viewmodel requiring an event and color
    @MainActor func makeViewModelEventDetailsSheet(event: Response.Event, color: Color) -> EventDetailsSheet.EventDetailsSheetViewModel {
        .init(event: event, color: color)
    }
    
    @MainActor func makeViewModelSidebar() -> SidebarMenu.SidebarViewModel { .init() }
}
