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
        schedules: [ScheduleData], completion: @escaping (Bool) -> Void
    ) {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self else { return }
            let events = schedules
                .flatMap { $0.days }
                .flatMap { $0.events }
                .filter { !($0.dateComponents!.hasDatePassed()) }
                .filter { $0.course.id == self.event.course.id }
            var couldSetNotifications = true
            
            for event in events {
                let notification = EventNotification(
                    id: event.id,
                    color: color.toHex() ?? "#FFFFFF",
                    dateComponents: event.dateComponents!,
                    categoryIdentifier: event.course.id,
                    content: event.toDictionary()
                )
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
            }
            completion(couldSetNotifications ? true : false)
        }
    }

    
    func checkNotificationIsSetForCourse() -> Void {
        notificationManager.isNotificationScheduled(categoryIdentifier: event.course.id) { result in
            DispatchQueue.main.async {
                if result {
                    self.isNotificationSetForCourse = true
                }
            }
        }
    }
    
    func checkNotificationIsSetForEvent() -> Void {
        notificationManager.isNotificationScheduled(eventId: event.id) { result in
            DispatchQueue.main.async {
                if result {
                    self.isNotificationSetForEvent = true
                }
            }
        }
    }
    
}
