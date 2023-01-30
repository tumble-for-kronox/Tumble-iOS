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
        @Published var currentNavigationView: TabType = .home
        @Published var selectedTab: TabType = .home
        @Published var showModal: Bool = true
        @Published var showDrawerSheet: Bool = false
        
        @Published var schoolIsChosen: Bool
        let databaseService: PreferenceServiceImpl
        let scheduleService: ScheduleServiceImpl
        let courseColorService: CourseColorServiceImpl
        let homePageViewModel: HomePageView.HomePageViewModel
        let accountPageViewModel: AccountPageView.AccountPageViewModel
        let schedulePageViewModel: ScheduleMainPageView.ScheduleMainPageViewModel
        let sideBarViewModel: SideBarContent.SideBarViewModel
        
        
        init(schoolIsChosen: Bool, databaseService: PreferenceServiceImpl, scheduleService: ScheduleServiceImpl, courseColorService: CourseColorServiceImpl) {
            self.schoolIsChosen = schoolIsChosen
            self.databaseService = databaseService
            self.scheduleService = scheduleService
            self.courseColorService = courseColorService
            
            self.homePageViewModel = ViewModelFactory().makeViewModelHomePage()
            self.accountPageViewModel = ViewModelFactory().makeViewModelAccountPage()
            self.schedulePageViewModel = ViewModelFactory().makeViewModelScheduleMainPage()
            self.sideBarViewModel = ViewModelFactory().makeViewModelSideBar()
            
        }
        
        func onSelectSchool(school: School) -> Void {
            
            databaseService.setSchool(id: school.id, closure: {})
            
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
        
        func onChangeTab(tab: TabType) -> Void {
            self.selectedTab = tab
        }

    }
}
