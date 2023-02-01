//
//  ViewModelFactory.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 2023-01-27.
//

import Foundation
import SwiftUI

class ViewModelFactory {
    private let scheduleService: ScheduleServiceImpl
    private let courseColorService: CourseColorServiceImpl
    private let preferenceService: PreferenceServiceImpl
    
    init(
        scheduleService: ScheduleServiceImpl = ScheduleServiceImpl(),
        courseColorService: CourseColorServiceImpl = CourseColorServiceImpl(),
        databaseService: PreferenceServiceImpl = PreferenceServiceImpl()) {
        self.scheduleService = scheduleService
        self.courseColorService = courseColorService
        self.preferenceService = databaseService
    }
    
    @MainActor func makeViewModelRoot() -> RootView.RootViewModel {
        .init(
            userNotOnBoarded: !preferenceService.isKeyPresentInUserDefaults(key: StoreKey.userOnboarded.rawValue))
    }
    
    @MainActor func makeViewModelApp() -> MainAppView.MainAppViewModel {
        .init(
            schoolIsChosen: preferenceService.isKeyPresentInUserDefaults(key: StoreKey.school.rawValue),
            preferenceService: self.preferenceService,
            scheduleService: self.scheduleService,
            courseColorService: self.courseColorService)
    }

    
    @MainActor func makeViewModelSearch() -> SearchParentView.SearchViewModel {
        .init(school: preferenceService.getDefaultSchool(), scheduleService: scheduleService, courseColorService: courseColorService)
    }
    
    @MainActor func makeViewModelHomePage() -> HomePageView.HomePageViewModel {
        .init(preferenceService: preferenceService)
    }
    
    @MainActor func makeViewModelScheduleMainPage() -> ScheduleMainPageView.ScheduleMainPageViewModel {
        .init(defaultViewType: preferenceService.getDefaultViewType(), scheduleService: scheduleService, courseColorService: courseColorService, preferenceService: preferenceService)
    }
    
    @MainActor func makeViewModelAccountPage() -> AccountPageView.AccountPageViewModel {
        .init()
    }
    
    @MainActor func makeViewModelOnBoarding() -> OnBoardingView.OnBoardingViewModel {
        .init(preferenceService: preferenceService)
    }
    
    @MainActor func makeViewModelEventSheet(event: Response.Event, color: Color) -> EventDetailsView.EventDetailsViewModel {
        .init(event: event, color: color)
    }
}
