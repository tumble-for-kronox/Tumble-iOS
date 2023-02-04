//
//  File.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 11/16/22.
//

import Foundation
import SwiftUI

enum ThemeMode: String {
    case light = "light"
    case dark = "dark"
}


extension MainAppView {
    @MainActor final class MainAppViewModel: ObservableObject {
        
        let viewModelFactory: ViewModelFactory = ViewModelFactory.shared
        
        @Inject var scheduleService: ScheduleService
        @Inject var courseColorService: CourseColorService
        @Inject var preferenceService: PreferenceService
        
        @Published var universityImage: Image?
        @Published var universityName: String?
        @Published var kronoxUrl: String?
        @Published var canvasUrl: String?
        @Published var domain: String?

        let homePageViewModel: HomePageView.HomePageViewModel
        let scheduleMainPageViewModel: ScheduleMainPageView.ScheduleMainPageViewModel
        let accountPageViewModel: AccountPageView.AccountPageViewModel
        
        init() {
            
            // ViewModels to subviews
            self.homePageViewModel = viewModelFactory.makeViewModelHomePage()
            self.scheduleMainPageViewModel = viewModelFactory.makeViewModelScheduleMainPage()
            self.accountPageViewModel = viewModelFactory.makeViewModelAccountPage()
            
            self.universityName = preferenceService.getUniversityName()
            self.universityImage = preferenceService.getUniversityImage()
            self.canvasUrl = preferenceService.getCanvasUrl()
            self.kronoxUrl = preferenceService.getUniversityKronoxUrl()
            self.domain = preferenceService.getUniversityDomain()
        }
        
        func updateUniversityLocalsForView() -> Void {
            self.universityImage = preferenceService.getUniversityImage()
            self.universityName = preferenceService.getUniversityName()
            self.kronoxUrl = preferenceService.getUniversityKronoxUrl()
            self.canvasUrl = preferenceService.getCanvasUrl()
            self.domain = preferenceService.getUniversityDomain()
        }
        
        func generateViewModelEventSheet(event: Response.Event, color: Color) -> EventDetailsSheetView.EventDetailsViewModel {
            return viewModelFactory.makeViewModelEventDetailsSheet(event: event, color: color)
        }
        
        func updateSchedulesChildView() -> Void {
            scheduleMainPageViewModel.loadSchedules()
        }
        
        func changeSchool(school: School, closure: @escaping () -> Void) -> Void {
            
            preferenceService.setSchool(id: school.id, closure: { [self] in
                scheduleService.removeAll { [weak self] result in
                    switch result {
                    case .failure(let error):
                        // Todo: Add error message for user
                        AppLogger.shared.info("Could not remove schedules: \(error)")
                    case .success:
                        // Todo: Add success message for user
                        AppLogger.shared.info("Removed all schedules from local storage")
                        self?.courseColorService.removeAll { result in
                            switch result {
                            case .failure(let error):
                                // Todo: Add error message for user
                                AppLogger.shared.info("Could not remove course colors: \(error)")
                            case .success:
                                // Todo: Add success message for user
                                AppLogger.shared.info("Removed all course colors from local storage")
                                closure()
                            }
                        }
                    }
                }
            })
        }
    }
}
