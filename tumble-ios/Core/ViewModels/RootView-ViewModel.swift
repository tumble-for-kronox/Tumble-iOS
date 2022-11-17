//
//  File.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 11/16/22.
//

import Foundation

enum Tab: String {
    case house = "house"
    case calendar = "list.bullet.clipboard"
    case account = "graduationcap"
    
    static let allValues = [house, calendar, account]
    
    var displayName: String {
        switch self {
        case .house:
            return "Home"
        case .calendar:
            return "Schedule"
        case .account:
            return "Account"
        }
        
    }
}

extension RootView {
    @MainActor class RootViewModel: ObservableObject {
        @Published var selectedTab: Tab = Tab.house
        @Published var menuOpened: Bool = false
        @Published var missingSchool: Bool = {
            let missingSchool: Bool? = !((UserDefaults.standard.getDefault(key: "SCHOOL") as? Bool) == nil)
            return missingSchool ?? true
        } ()
        
        func selectSchool(school: String) -> Void {
            UserDefaults.standard.setSchool(name: school)
            print("Set school to \(school)")
            missingSchool = false
        }
        
        func changeTab(index: Int) -> Void {
            selectedTab = Tab.allValues[index]
        }
        
        func toggleDrawer() -> Void {
            menuOpened.toggle()
        }
    }
}
