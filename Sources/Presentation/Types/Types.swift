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
    case account = "graduationcap"
    
    static let allValues = [home, bookmarks, account]
    
    var displayName: String {
        switch self {
        case .home:
            return NSLocalizedString("Home", comment: "")
        case .bookmarks:
            return NSLocalizedString("Bookmarks", comment: "")
        case .account:
            return NSLocalizedString("Account", comment: "")
        }
    }
}

enum BookmarksViewType: String {
    case list
    case calendar
    
    var displayName: String {
        switch self {
        case .calendar:
            return NSLocalizedString("Calendar", comment: "")
        case .list:
            return NSLocalizedString("List", comment: "")
        }
    }
    
    static let allValues: [BookmarksViewType] = [list, calendar]
}
