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
        @Published var universityImage: Image?
        @Published var universityName: String?
        
        
        // Service
        let preferenceService: PreferenceServiceImpl
        let scheduleService: ScheduleServiceImpl
        let courseColorService: CourseColorServiceImpl
        
        // Child ViewModels
        let homePageViewModel: HomePageView.HomePageViewModel
        let accountPageViewModel: AccountPageView.AccountPageViewModel
        let schedulePageViewModel: ScheduleMainPageView.ScheduleMainPageViewModel
        
        // Initialize dependencies from ViewModelFactory class
        init(preferenceService: PreferenceServiceImpl, scheduleService: ScheduleServiceImpl, courseColorService: CourseColorServiceImpl, universityName: String?, universityImage: Image?) {
            self.preferenceService = preferenceService
            self.scheduleService = scheduleService
            self.courseColorService = courseColorService
            
            self.homePageViewModel = ViewModelFactory().makeViewModelHomePage()
            self.accountPageViewModel = ViewModelFactory().makeViewModelAccountPage()
            self.schedulePageViewModel = ViewModelFactory().makeViewModelScheduleMainPage()
            
            self.universityName = universityName
            self.universityImage = universityImage
        }
        
        func updateUniversityLocalsForView() -> Void {
            self.universityImage = preferenceService.getUniversityImage()
            self.universityName = preferenceService.getUniversityName()
        }
        
        func changeSchool(school: School, closure: @escaping () -> Void) -> Void {
            
            preferenceService.setSchool(id: school.id, closure: { [self] in
                scheduleService.removeAll { [self] result in
                    switch result {
                    case .failure(let error):
                        // Todo: Add error message for user
                        print("Could not remove schedules: \(error)")
                    case .success:
                        // Todo: Add success message for user
                        print("Removed all schedules from local storage")
                        courseColorService.removeAll { result in
                            switch result {
                            case .failure(let error):
                                // Todo: Add error message for user
                                print("Could not remove course colors: \(error)")
                            case .success:
                                // Todo: Add success message for user
                                print("Removed all course colors from local storage")
                                self.checkForNewSchedules()
                                closure()
                            }
                        }
                    }
                }
            })
        }
        
        func checkForNewSchedules() -> Void {
            self.schedulePageViewModel.loadSchedules()
        }
    }
}
