//
//  EventDetailsView-ViewModel.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 2023-02-01.
//

import Foundation
import SwiftUI

extension EventDetailsSheetView {
    @MainActor final class EventDetailsViewModel: ObservableObject {
        
        @Inject var notificationManager: NotificationManager
        @Inject var preferenceService: PreferenceService
        @Inject var scheduleService: ScheduleService
        
        @Published var event: Response.Event
        @Published var color: Color?
        @Published var isNotificationSetForEvent: Bool = false
        @Published var isNotificationSetForCourse: Bool = false
        @Published var notificationOffset: Int = 60
        
        init(event: Response.Event, color: Color) {
            self.event = event
            self.color = color
            self.checkNotificationIsSetForEvent()
            self.checkNotificationIsSetForCourse()
            self.notificationOffset = preferenceService.getNotificationOffset()
        }
        
        func setEventSheetView(event: Response.Event, color: Color) -> Void {
            self.event = event
            self.color = color
        }
        
        func scheduleNotificationForEvent(completion: @escaping (Bool) -> Void) -> Void {
            let userOffset: Int = preferenceService.getNotificationOffset()
            
            // Create notification for event without categoryIdentifier,
            // since it does not need to be set for the entire course
            let notification = Notification(
                id: event.id,
                title: event.title,
                subtitle: event.course.englishName,
                dateComponents: event.dateComponents!,
                categoryIdentifier: nil)
            
            notificationManager.scheduleNotification(for: notification, userOffset: userOffset, completion: { result in
                switch result {
                case .success(let success):
                    AppLogger.shared.info("Scheduled \(success) notifications")
                    completion(true)
                case .failure(let failure):
                    AppLogger.shared.info("Failed to schedule notifications -> \(failure)")
                    completion(false)
                }
            })
        }
        
        func cancelNotificationForEvent() -> Void {
            notificationManager.cancelNotification(for: event.id)
        }
        
        func cancelNotificationsForCourse() -> Void {
            notificationManager.cancelNotifications(with: event.course.id)
        }
        
        func scheduleNotificationsForCourse(completion: @escaping (Bool) -> Void) -> Void {
            scheduleService.load { [weak self] result in
                guard let self = self else { return }
                switch result {
                case .success(let success):
                    let schedules = success
                    self.applyNotificationForScheduleEventsInCourse(schedules: schedules) { success in
                        if success {
                            completion(true)
                        } else {
                            completion(false)
                        }
                    }
                case .failure(let failure):
                    AppLogger.shared.info("\(failure.localizedDescription)")
                    // TODO: Handle error in view
                }
            }
        }
        
        // Apply scheduleNotifaction for each event under specific course id
        fileprivate func applyNotificationForScheduleEventsInCourse(schedules: [Response.Schedule], completion: @escaping (Bool) -> Void)
                -> Void {
            let events = schedules
                .flatMap { $0.days }
                .flatMap { $0.events }
                .filter { $0.course.id == self.event.course.id }

                    events.forEach { event in
                        let notification = Notification(
                            id: event.id,
                            title: event.course.englishName,
                            subtitle: event.title,
                            dateComponents: event.dateComponents!,
                            categoryIdentifier: event.course.id)
                        // Sets notifications for course. If events already have notifications set for them without a categoryIdentifier,
                        // they will be reset in order to be able to remove course notifications on a categoryIdentifier basis
                        self.notificationManager.scheduleNotification(for: notification, userOffset: self.notificationOffset) { result in
                            switch result {
                            case .success(let success):
                                AppLogger.shared.info("Scheduled \(success) notifications")
                            case .failure(let failure):
                                AppLogger.shared.info("Failed to schedule notifications -> \(failure)")
                                completion(false)
                            }
                        }
                        AppLogger.shared.info("Set notification for \(event.title)")
                        completion(true)
                    }
        }
        
        fileprivate func checkNotificationIsSetForCourse() -> Void {
            notificationManager.isNotificationScheduled(categoryIdentifier: event.course.id) { result in
                DispatchQueue.main.async {
                    if result {
                        self.isNotificationSetForCourse = true
                    }
                }
            }
        }
        
        fileprivate func checkNotificationIsSetForEvent() -> Void {
            notificationManager.isNotificationScheduled(eventId: event.id) { result in
                DispatchQueue.main.async {
                    if result {
                        self.isNotificationSetForEvent = true
                    }
                }
            }
        }
    }
}
