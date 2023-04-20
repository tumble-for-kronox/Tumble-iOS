//
//  EventDetailsSheetModelExtension.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 2023-04-01.
//

import Foundation

extension EventDetailsSheetViewModel {
    // Apply scheduleNotifaction for each event under specific course id
    func applyNotificationForScheduleEventsInCourse(
        events: [Event], completion: @escaping (Bool) -> Void
    ) {
        var couldSetNotifications = true
        for event in events {
            if let notification = notificationManager.createNotificationFromEvent(event: event) {
                notificationManager.scheduleNotification(
                    for: notification,
                    type: .event,
                    userOffset: notificationOffset
                ) { result in
                    switch result {
                    case .success(let success):
                        AppLogger.shared.debug("Scheduled \(success) notifications")
                    case .failure(let failure):
                        AppLogger.shared.critical("Failed to schedule notifications for course -> \(failure)")
                        couldSetNotifications = false
                        return
                    }
                }
                if !couldSetNotifications { break }
                AppLogger.shared.debug("Set notification for \(event.title)")
            } else {
                AppLogger.shared.error("Could not set event")
            }
        }
        completion(couldSetNotifications ? true : false)
    }
    
    func checkNotificationIsSetForCourse() {
        if let course = event.course {
            notificationManager.isNotificationScheduled(categoryIdentifier: course.courseId) { result in
                DispatchQueue.main.async {
                    if result {
                        self.isNotificationSetForCourse = true
                    }
                }
            }
        }
    }
    
    func checkNotificationIsSetForEvent() {
        notificationManager.isNotificationScheduled(eventId: event.eventId) { result in
            DispatchQueue.main.async {
                if result {
                    self.isNotificationSetForEvent = true
                }
            }
        }
    }
}
