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


extension AppNavigatorView {
    @MainActor class AppNavigatorViewModel: ObservableObject {
        @Published var currentDrawerSheetView: AnyView? = nil
        @Published var currentNavigationView: TabType = .home
        @Published var animateTransition: Bool = false
        @Published var selectedTab: TabType = .home
        @Published var showModal: Bool = {
            return true
        } ()
        @Published var showDrawerSheet: Bool = false
        @Published var menuOpened: Bool = false
        @Published var schoolIsChosen: Bool = UserDefaults.standard.getDefaultSchool() != nil
        private var userDefaults: UserDefaults = UserDefaults.standard

        
        func onToggleDrawer() -> Void {
            self.menuOpened.toggle()
        }
        
        func onSelectSchool(school: School) -> Void {
            UserDefaults.standard.setSchool(id: school.id)
            ScheduleStore.removeAll { result in
                switch result {
                case .failure(let error):
                    // Todo: Add error message for user
                    print("Could not remove schedules: \(error)")
                case .success:
                    // Todo: Add success message for user
                    print("Removed all schedules from local storage")
                }
            }
            CourseColorStore.removeAll { result in
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
        
        func onClickDrawerRow(drawerRowType: DrawerRowType) -> Void {
            switch drawerRowType {
            case .school:
                self.currentDrawerSheetView = AnyView(SchoolSelectView(selectSchoolCallback: { schoolName in
                    self.onSelectSchool(school: schoolName)
                    self.showDrawerSheet = false
                }))
            default:
                self.currentDrawerSheetView = AnyView(Text("STUB"))
            }
            self.showDrawerSheet = true
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
