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
    case bookmarks = "bookmark"
    case account = "person"
    
    static let allValues = [home, bookmarks, account]
    
    var navigationView: BottomTabType {
            switch self {
            case .home:
                return .home
            case .bookmarks:
                return .bookmarks
            case .account:
                return .account

            }
        }
    
    var displayName: String {
        switch self {
        case .home:
            return "Home"
        case .bookmarks:
            return "Bookmarks"
        case .account:
            return "Account"
        }
    }
}

enum SideBarTabType: String {
    case none = ""
    case notifications = "Notifications" // Opens sheet
    case bookmarks = "Bookmarks"
    case more = "More"
    case school = "Schools" // Opens sheet
    case support = "Support" // Opens sheet
    case logOut = "Log out" // Performs api call
}

enum BookmarksViewType: String {
    case list = "List"
    case calendar = "Calendar"
    
    static let allValues: [BookmarksViewType] = [list, calendar]
}
