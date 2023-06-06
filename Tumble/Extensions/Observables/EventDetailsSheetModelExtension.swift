//
//  EventDetailsSheetModelExtension.swift
//  Tumble
//
//  Created by Adis Veletanlic on 2023-04-01.
//

import Foundation

extension EventDetailsSheetViewModel {
    // Apply scheduleNotifaction for each event under specific course id
    @MainActor
    func applyNotificationForScheduleEventsInCourse(events: [Event]) async throws -> Bool {
        for event in events {
            if let notification = notificationManager.createNotificationFromEvent(event: event) {
                try await notificationManager.scheduleNotification(
                    for: notification,
                    type: .event,
                    userOffset: notificationOffset
                )
                AppLogger.shared.debug("Set notification for \(event.title)")
            } else {
                AppLogger.shared.error("Permission error: Not allowed")
                return false
            }
        }
        return true
    }

    @MainActor
    func checkNotificationIsSetForCourse() {
        if let course = event.course {
            let courseId = course.courseId
            Task {
                let result = await notificationManager.isNotificationScheduled(categoryIdentifier: courseId)
                DispatchQueue.main.async {
                    self.isNotificationSetForCourse = result
                }
            }
        }
    }
    
    @MainActor
    func checkNotificationIsSetForEvent() {
        let eventId = event.eventId
        Task {
            let result = await notificationManager.isNotificationScheduled(eventId: eventId)
            DispatchQueue.main.async {
                self.isNotificationSetForEvent = result
            }
        }
    }

}
