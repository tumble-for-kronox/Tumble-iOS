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

extension TabSwitcherView {
    @MainActor class TabSwitcherViewModel: ObservableObject {
        @Published var currentDrawerSheetView: AnyView? = nil
        @Published var currentNavigationView: AnyView = AnyView(HomePageView())
        @Published var animateTransition: Bool = false
        @Published var selectedTab: TabType = .home
        @Published var showModal: Bool = {
            return true
        } ()
        @Published var showDrawerSheet: Bool = false
        @Published var menuOpened: Bool = false
        private var userDefaults: UserDefaults = UserDefaults.standard
        
        func onToggleDrawer() -> Void {
            self.menuOpened.toggle()
        }
        
        func onSelectSchool(school: School) -> Void {
            UserDefaults.standard.setSchool(id: school.id)
            print("Set school to \(school.name)")
        }
        
        func onClickDrawerRow(drawerSheetType: Int) -> Void {
            print(drawerSheetType)
            switch drawerSheetType {
            case DrawerBottomSheetType.school.rawValue:
                self.currentDrawerSheetView = AnyView(SchoolSelectView(selectSchoolCallback: { schoolName in
                    self.onSelectSchool(school: schoolName)
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
            switch self.selectedTab {
            case .home:
                self.currentNavigationView = AnyView(HomePageView().onAppear{
                    self.onEndTransitionAnimation()
                })
            case .schedule:
                self.currentNavigationView = AnyView(ScheduleMainPageView().onAppear{
                    self.onEndTransitionAnimation()
                })
            case .account:
                self.currentNavigationView = AnyView(Text("Account").onAppear {
                    self.onEndTransitionAnimation()
                })
            }
        }
        
        func onEndTransitionAnimation() -> Void {
            self.animateTransition = false
        }
        
    }
}
