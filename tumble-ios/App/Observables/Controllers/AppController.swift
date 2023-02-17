//
//  AppNotificationState.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 2023-02-09.
//

import Foundation

// Observable state from views to open sheets from
// pressing external notifications in order to navigate
// to certain views with attributes
class AppController: ObservableObject {
    
    static let shared: AppController = AppController()
    
    @Published var eventSheet : EventDetailsSheetModel?
    @Published var selectedTab: TabbarTabType = .home
    @Published var toast: Toast? = nil
    @Published var selectedSideBarTab: SidebarTabType = .none
    @Published var sideBarSheet: SideBarSheetModel? = nil
    @Published var showSideBar: Bool = false
}
