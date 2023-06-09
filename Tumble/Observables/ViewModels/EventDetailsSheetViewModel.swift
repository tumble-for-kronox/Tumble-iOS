//
//  EventDetailsSheetViewModel.swift
//  Tumble
//
//  Created by Adis Veletanlic on 2023-02-01.
//

import Combine
import Foundation
import RealmSwift
import SwiftUI

final class EventDetailsSheetViewModel: ObservableObject {
    @Inject var notificationManager: NotificationManager
    @Inject var preferenceService: PreferenceService
    @Inject var realmManager: RealmManager
    
    @Published var event: Event
    @Published var color: Color
    @Published var isNotificationSetForEvent: Bool = false
    @Published var isNotificationSetForCourse: Bool = false
    @Published var notificationOffset: Int = 60
    @Published var notificationsAllowed: Bool = false
    
    var oldColor: Color
        
    init(event: Event) {
        self.event = event
        color = event.course?.color.toColor() ?? .white
        oldColor = event.course?.color.toColor() ?? .white
        notificationOffset = preferenceService.getNotificationOffset()
        Task.detached(priority: .userInitiated) { [weak self] in
            guard let self else { return }
            let allowed = await self.userAllowedNotifications()
            DispatchQueue.main.async {
                self.notificationsAllowed = allowed
            }
            await self.checkNotificationIsSetForEvent()
            await self.checkNotificationIsSetForCourse()
        }
    }
    
    @MainActor func setEventSheetView(event: Event, color: Color) {
        self.event = event
    }
    
    @MainActor func cancelNotificationForEvent() {
        isNotificationSetForEvent = false
        notificationManager.cancelNotification(for: event.eventId)
    }
    
    @MainActor func cancelNotificationsForCourse() {
        isNotificationSetForCourse = false
        isNotificationSetForEvent = false
        if let course = event.course {
            Task {
                await notificationManager.cancelNotifications(with: course.courseId)
            }
        }
    }
    
    @MainActor func scheduleNotificationForEvent() {
        let userOffset: Int = preferenceService.getNotificationOffset()
        
        // Create notification for event without categoryIdentifier,
        // since it does not need to be set for the entire course
        let notification = EventNotification(
            id: self.event.eventId,
            dateComponents: self.event.dateComponents!,
            categoryIdentifier: nil,
            content: self.event.toDictionary()
        )
        
        Task.detached(priority: .userInitiated) { [weak self] in
            guard let self else { return }
            do {
                try await self.notificationManager.scheduleNotification(for: notification, type: .event, userOffset: userOffset)
                DispatchQueue.main.async {
                    self.isNotificationSetForEvent = true
                }
            } catch {
                AppLogger.shared.critical("Failed to schedule notifications -> \(error)")
            }
        }
    }

    @MainActor func updateCourseColor() {
        if oldColor == color { return }
        guard let color = color.toHex(),
              let courseId = event.course?.courseId
        else { return }
                
        realmManager.updateCourseColors(courseId: courseId, color: color)
    }

    @MainActor func scheduleNotificationsForCourse() {
        let schedules = realmManager.getAllSchedules()
        let events = schedules
            .flatMap { $0.days }
            .flatMap { $0.events }
            .filter { !($0.dateComponents!.hasDatePassed()) }
            .filter { $0.course?.courseId == event.course?.courseId }
        Task.detached(priority: .background) { [weak self] in
            guard let self else { return }
            do {
                let result = try await self.applyNotificationForScheduleEventsInCourse(events: events)
                if result {
                    DispatchQueue.main.async { [weak self] in
                        self?.isNotificationSetForCourse = true
                        self?.isNotificationSetForEvent = true
                        // TODO: Display success popup
                    }
                }
            } catch {
                // TODO: Display error popup
            }
        }
    }
    
    func userAllowedNotifications() async -> Bool {
        do {
            return try await notificationManager.notificationsAreAllowed()
        } catch {
            return false
        }
    }

}
