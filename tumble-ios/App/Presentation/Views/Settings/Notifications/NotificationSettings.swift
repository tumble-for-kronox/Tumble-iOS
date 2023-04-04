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
    let rescheduleNotifications: (Int, Int) -> Void
    
    var offsetDisplayName: String {
        let hours = offset / 60
        let minuteString = NSLocalizedString("minutes", comment: "")
        let hourString = NSLocalizedString("hour", comment: "")
        let hoursString = NSLocalizedString("hours", comment: "")
        let hourPostfix = hours == 1 ? hourString : hoursString
        return hours < 1 ? "\(offset % 60) \(minuteString)" : "\(hours) \(hourPostfix)"
    }
    
    var body: some View {
        CustomList {
            CustomListGroup {
                ListRowActionItem(
                    title: NSLocalizedString("Set notifications for all events", comment: ""),
                    image: "bell.badge",
                    imageColor: .primary,
                    action: scheduleNotificationsForAllCourses
                )
                Divider()
                ListRowActionItem(
                    title: NSLocalizedString("Cancel all notifications", comment: ""),
                    image: "bell.slash",
                    imageColor: .primary,
                    action: clearAllNotifications)
            }
            CustomListGroup {
                ListRowNavigationItem(
                    title: NSLocalizedString("Notification offset", comment: ""),
                    current: offsetDisplayName,
                    destination: AnyView(NotificationOffsetSettings(
                        offset: $offset,
                        rescheduleNotifications: rescheduleNotifications)))
            }
        }
        .padding(.top, 20)
    }
}
