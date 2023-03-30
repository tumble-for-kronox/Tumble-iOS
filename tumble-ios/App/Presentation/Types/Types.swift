//
//  Types.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 11/20/22.
//

import Foundation

// Bottom tab bar
enum TabbarTabType: String {
    case home = "house"
    case bookmarks = "bookmark"
    case account = "person"
    
    static let allValues = [home, bookmarks, account]
    
    var displayName: String {
        switch self {
        case .home:
            return NSLocalizedString("Home", comment: "Home")
        case .bookmarks:
            return NSLocalizedString("Bookmarks", comment: "Bookmarks")
        case .account:
            return NSLocalizedString("Account", comment: "Account")
        }
    }
}

enum BookmarksViewType: String {
    case list = "list"
    case calendar = "calendar"
    
    var displayName: String {
        switch self {
        case .calendar:
            return NSLocalizedString("List", comment: "List")
        case .list:
            return NSLocalizedString("Calendar", comment: "Calendar")
        }
    }
    
    static let allValues: [BookmarksViewType] = [list, calendar]
}

