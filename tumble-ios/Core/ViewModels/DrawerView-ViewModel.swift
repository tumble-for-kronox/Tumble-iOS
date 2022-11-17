//
//  DrawerViewModel.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 11/17/22.
//

import Foundation
import SwiftUI

enum DrawerRowType: String {
    case school = "school"
    case theme = "theme"
    case language = "language"
    case schedules = "schedules"
    case notifications = "notifications"
    
    static let allValues = [school, theme, language, schedules, notifications]
}

extension DrawerContent {
    @MainActor class DrawerViewModel: ObservableObject {
        @Published var drawerView: String = ""
        @Published var visibleBottomSheet: Bool = true
        
        func onClick(index: Int) -> Void {
            self.visibleBottomSheet = true
        }
    }
}
