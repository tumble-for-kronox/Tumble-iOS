//
//  Types.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 11/20/22.
//

import Foundation

// Bottom tab bar
enum TabType: String {
    case home = "house"
    case schedule = "list.bullet.clipboard"
    case account = "graduationcap"
    
    static let allValues = [home, schedule, account]
    
    var navigationView: TabType {
            switch self {
            case .home:
                return .home
            case .schedule:
                return .schedule
            case .account:
                return .account
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
        }
    }
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
