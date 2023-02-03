//
//  ViewModelFactory.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 2023-01-27.
//

import Foundation
import SwiftUI

class ViewModelFactory {
    
    // Injects repositories into view models
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
            preferenceService: self.preferenceService,
            scheduleService: self.scheduleService,
            courseColorService: self.courseColorService,
            universityName: self.preferenceService.getUniversityName(),
            universityImage: self.preferenceService.getUniversityImage(),
            kronoxUrl: self.preferenceService.getUniversityKronoxUrl(),
            canvasUrl: self.preferenceService.getCanvasUrl(),
            domain: self.preferenceService.getUniversityDomain()
        )
    }

    
    @MainActor func makeViewModelSearch() -> SearchParentView.SearchViewModel {
        .init(school: preferenceService.getDefaultSchool(), scheduleService: scheduleService, courseColorService: courseColorService)
    }
    
    @MainActor func makeViewModelHomePage() -> HomePageView.HomePageViewModel {
        .init(
            preferenceService: preferenceService
        )
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
    
    @MainActor func makeViewModelEventDetailsSheet(event: Response.Event, color: Color) -> EventDetailsSheetView.EventDetailsViewModel {
        .init(event: event, color: color)
    }
}
