//
//  NotificationSettings.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 3/29/23.
//

import SwiftUI

struct NotificationSettings: View {
    
    @AppStorage(StoreKey.notificationOffset.rawValue) var offset: Int = 60
    let clearAllNotifications: () -> Void
    let scheduleNotificationsForAllCourses: () -> Void
   
    var body: some View {
        // List of options for notifications
        List {
            Section {
                SettingsButton(
                    onClick: scheduleNotificationsForAllCourses,
                    title: "Set notifications for all events",
                    image: "bell.badge"
                )
                SettingsButton(
                    onClick: clearAllNotifications,
                    title: "Cancel all notifications",
                    image: "bell.slash"
                )
            }
            Section {
                NavigationLink(destination: AnyView(
                    NotificationOffsetSettings(offset: $offset)), label: {
                    SettingsNavLink(title: "Notification offset", current: offset / 60 < 1 ? "\(offset % 60) minutes" : "\(offset / 60) hour(s)")
                })
            }
        }
    }
}
