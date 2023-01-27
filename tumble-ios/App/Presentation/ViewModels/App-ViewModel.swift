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


extension AppView {
    @MainActor final class AppViewModel: ObservableObject {
        @Published var currentDrawerSheetView: DrawerSheetViewType? = nil
        @Published var currentNavigationView: TabType = .home
        @Published var animateTransition: Bool = false
        @Published var selectedTab: TabType = .home
        @Published var showModal: Bool = true
        @Published var showDrawerSheet: Bool = false
        
        @Published var schoolIsChosen: Bool;
        let databaseService: PreferenceServiceImpl
        let scheduleService: ScheduleServiceImpl
        let courseColorService: CourseColorServiceImpl
        let homePageViewModel: HomePageView.HomePageViewModel
        let accountPageViewModel: AccountPageView.AccountPageViewModel
        let schedulePageViewModel: ScheduleMainPageView.ScheduleMainPageViewModel
        
        
        init(schoolIsChosen: Bool, databaseService: PreferenceServiceImpl, scheduleService: ScheduleServiceImpl, courseColorService: CourseColorServiceImpl) {
            self.schoolIsChosen = schoolIsChosen
            self.databaseService = databaseService
            self.scheduleService = scheduleService
            self.courseColorService = courseColorService
            
            self.homePageViewModel = ViewModelFactory().makeViewModelHomePage()
            self.accountPageViewModel = ViewModelFactory().makeViewModelAccountPage()
            self.schedulePageViewModel = ViewModelFactory().makeViewModelScheduleMainPage()
            
        }
        
        func onSelectSchool(school: School) -> Void {
            
            databaseService.setSchool(id: school.id)
            
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
        
        // Assigns the corresponding drawer view type
        // based on which row in the drawer was clicked
        func onClickDrawerRow(drawerRowType: DrawerRowType) -> Void {
            switch drawerRowType {
            case .school:
                self.currentDrawerSheetView = .school
            case .schedules:
                self.currentDrawerSheetView = .schedules
            case .support:
                self.currentDrawerSheetView = .support
            default:
                self.currentDrawerSheetView = nil
            }
            if self.currentDrawerSheetView != nil {
                self.showDrawerSheet = true
            }
        }
        
        func onToggleDrawerSheet() -> Void {
            self.showDrawerSheet = false
        }
        
        func onChangeTab(tab: TabType) -> Void {
            self.animateTransition = true
            self.selectedTab = tab
        }

        
        func onEndTransitionAnimation() -> Void {
            self.animateTransition = false
        }
    }
}
