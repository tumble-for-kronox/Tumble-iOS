//
//  Types.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 11/20/22.
//

import Foundation

// Bottom tab bar
enum BottomTabType: String {
    case home = "house"
    case schedule = "list.bullet.clipboard"
    case account = "person"
    case settings = "gearshape"
    
    static let allValues = [home, schedule, account]
    
    var navigationView: BottomTabType {
            switch self {
            case .home:
                return .home
            case .schedule:
                return .schedule
            case .account:
                return .account
            case .settings:
                return .settings
            }
        }
    
    var displayName: String {
        switch self {
        case .home:
            return "Home"
        case .schedule:
            return "Schedule"
        case .account:
            return "Account"
        case .settings:
            return "Settings"
        }
    }
}

enum SideBarTabType: String {
    case home = "Home"
    case notifications = "Notifications" // Opens sheet
    case schedule = "Schedules"
    case settings = "Settings"
    case school = "Schools" // Opens sheet
    case support = "Support" // Opens sheet
    case account = "Account"
    case theme = "Theme" // Opens sheet
    case logOut = "" // Performs api call
}

// Drawer sheet type specifically for the settings menu
enum DrawerBottomSheetType: Int {
    case language = 0
    case notifications = 1
    case schedules = 2
    case school = 3
    case theme = 4
    case support = 5
}
