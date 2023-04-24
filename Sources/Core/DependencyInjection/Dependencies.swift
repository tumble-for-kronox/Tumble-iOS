//
//  Dependencies.swift
//  Tumble
//
//  Created by Adis Veletanlic on 2023-02-03.
//

import Foundation

/// Initialize dependencies used primarily in ViewModels
/// and Controllers, using our custom dependency framework.
actor Dependencies {
    init() {
        @Provider var kronoxManager = KronoxManager()
        @Provider var notificationManager = NotificationManager()
        @Provider var preferenceService = PreferenceService()
        @Provider var authManager = AuthManager()
        @Provider var userController = UserController()
        @Provider var schoolManager = SchoolManager()
        @Provider var realmManager = RealmManager()
    }
}
