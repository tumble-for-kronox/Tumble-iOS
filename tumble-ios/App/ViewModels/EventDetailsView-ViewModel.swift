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
        
        func scheduleNotificationForEvent() -> Void {
            let userOffset: Int = preferenceService.getNotificationOffset()
            
            // Create notification for event without categoryIdentifier,
            // since it does not need to be set for the entire course
            let notification = Notification(
                id: event.id,
                title: event.title,
                subtitle: event.course.englishName,
                dateComponents: event.dateComponents!,
                categoryIdentifier: nil)
            notificationManager.scheduleNotification(for: notification, userOffset: userOffset)
        }
        
        func cancelNotificationForEvent() -> Void {
            notificationManager.cancelNotification(for: event.id)
        }
        
        func cancelNotificationsForCourse() -> Void {
            notificationManager.cancelNotifications(with: event.course.id)
        }
        
        func scheduleNotificationsForCourse() -> Void {
            scheduleService.load { [weak self] result in
                switch result {
                case .success(let success):
                    let schedules = success
                    self?.applyNotificationForScheduleEventsInCourse(schedules: schedules)
                case .failure(let failure):
                    AppLogger.shared.info("\(failure.localizedDescription)")
                    // TODO: Handle error in view
                }
            }
        }
        
        // Apply scheduleNotifaction for each event under specific course id
        fileprivate func applyNotificationForScheduleEventsInCourse(schedules: [Response.Schedule]) -> Void {
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
                self.notificationManager.scheduleNotification(
                    for: notification,
                    userOffset: self.notificationOffset)
                AppLogger.shared.info("Set notification for \(event.title)")
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
