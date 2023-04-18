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
        schedules: [Schedule], completion: @escaping (Bool) -> Void
    ) {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self else { return }
            let events = self.findCourseEvents()
            var couldSetNotifications = true
            for event in events {
                if let notification = self.notificationManager.createNotificationFromEvent(event: event) {
                    self.notificationManager.scheduleNotification(
                        for: notification,
                        type: .event,
                        userOffset: self.notificationOffset
                    ) { result in
                        switch result {
                        case .success(let success):
                            AppLogger.shared.info("Scheduled \(success) notifications")
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
    }
    
    func findCourseEvents() -> [Event] {
        if let course = event.course {
            let events = schedules
                .flatMap { $0.days }
                .flatMap { $0.events }
                .filter { !($0.dateComponents!.hasDatePassed()) }
                .filter { $0.course?._id == course._id }
            return events
        }
        return []
    }

    
    func checkNotificationIsSetForCourse() -> Void {
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
    
    func checkNotificationIsSetForEvent() -> Void {
        notificationManager.isNotificationScheduled(eventId: event.eventId) { result in
            DispatchQueue.main.async {
                if result {
                    self.isNotificationSetForEvent = true
                }
            }
        }
    }
    
}
