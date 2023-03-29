//
//  NotificationSettings.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 3/29/23.
//

import SwiftUI

struct NotificationSettings: View {
    let clearAllNotifications: () -> Void
    let scheduleNotificationsForAllCourses: () -> Void
   
    var body: some View {
        // List of options for notifications
        VStack {
            SettingsButton(image: "bell.slash", title: "Cancel all notifications", onClick: clearAllNotifications)
            SettingsButton(image: "bell.badge", title: "Set notifications for all schedules", onClick: scheduleNotificationsForAllCourses)
            Spacer()
        }
        .padding(.top, 25)
    }
}
