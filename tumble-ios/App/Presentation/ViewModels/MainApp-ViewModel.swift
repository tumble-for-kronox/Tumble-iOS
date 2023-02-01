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
        @Published var currentSideBarSheetView: SideBarSheetViewType? = nil
        @Published var showModal: Bool = true
        @Published var showDrawerSheet: Bool = false
        @Published var schoolIsChosen: Bool
        
        // Service
        let preferenceService: PreferenceServiceImpl
        let scheduleService: ScheduleServiceImpl
        let courseColorService: CourseColorServiceImpl
        
        // Child ViewModels
        let homePageViewModel: HomePageView.HomePageViewModel
        let accountPageViewModel: AccountPageView.AccountPageViewModel
        let schedulePageViewModel: ScheduleMainPageView.ScheduleMainPageViewModel
        
        
        init(schoolIsChosen: Bool, preferenceService: PreferenceServiceImpl, scheduleService: ScheduleServiceImpl, courseColorService: CourseColorServiceImpl) {
            self.schoolIsChosen = schoolIsChosen
            self.preferenceService = preferenceService
            self.scheduleService = scheduleService
            self.courseColorService = courseColorService
            
            self.homePageViewModel = ViewModelFactory().makeViewModelHomePage()
            self.accountPageViewModel = ViewModelFactory().makeViewModelAccountPage()
            self.schedulePageViewModel = ViewModelFactory().makeViewModelScheduleMainPage()
            
        }
        
        func getUniversityImage() -> Image? {
            guard let school: School = self.preferenceService.getDefaultSchool() else { return nil }

            
            let schoolImage: Image = schools.first(where: {$0.name == school.name})!.logo
            return schoolImage
        }
        
        func getUniversityName() -> String? {
            guard let school: School = self.preferenceService.getDefaultSchool() else { return nil }

            
            let schoolName: String = schools.first(where: {$0.name == school.name})!.name
            return schoolName
        }
        
        func onSelectSchool(school: School) -> Void {
            
            preferenceService.setSchool(id: school.id, closure: {})
            
            scheduleService.removeAll { result in
                switch result {
                case .failure(let error):
                    // Todo: Add error message for user
                    print("Could not remove schedules: \(error)")
                case .success:
                    // Todo: Add success message for user
                    print("Removed all schedules from local storage")
                }
            }
            courseColorService.removeAll { result in
                switch result {
                case .failure(let error):
                    // Todo: Add error message for user
                    print("Could not remove course colors: \(error)")
                case .success:
                    // Todo: Add success message for user
                    print("Removed all course colors from local storage")
                }
            }
            print("Set school to \(school.name)")
            self.schoolIsChosen = true
        }
        
        func onToggleDrawerSheet() -> Void {
            self.showDrawerSheet = false
        }
    }
}
