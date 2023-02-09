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
class AppDelegateViewStateManager: ObservableObject {
    static let shared = AppDelegateViewStateManager()
    @Published var eventSheet : EventDetailsSheetModel?
    @Published var selectedTab: TabbarTabType = .home
}
