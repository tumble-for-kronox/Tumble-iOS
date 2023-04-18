//
//  EventDetailsSheetViewModel.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 2023-02-01.
//

import Foundation
import SwiftUI
import Combine

final class EventDetailsSheetViewModel: ObservableObject {
    
    @Inject var notificationManager: NotificationManager
    @Inject var preferenceService: PreferenceService
    
    @Published var event: Event
    @Published var color: Color
    @Published var isNotificationSetForEvent: Bool = false
    @Published var isNotificationSetForCourse: Bool = false
    @Published var notificationOffset: Int = 60
    @Published var notificationsAllowed: Bool = false
    @Published var schedules: [Schedule] = []
    
    private var cancellables = Set<AnyCancellable>()
    
    init(event: Event) {
        self.event = event
        self.color = event.course?.color.toColor() ?? .white
        checkNotificationIsSetForEvent()
        checkNotificationIsSetForCourse()
        notificationOffset = preferenceService.getNotificationOffset()
        userAllowedNotifications(completion: { value in
            DispatchQueue.main.async { [weak self] in
                guard let self else { return }
                self.notificationsAllowed = value
            }
        })
    }
    
    func updateCourseColor() -> Void {
        // TODO: Add function to update course colors for a schedule
    }
    
    func setEventSheetView(event: Event, color: Color) -> Void {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            self.event = event
        }
    }
    
    
    func cancelNotificationForEvent() -> Void {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            self.isNotificationSetForEvent = false
        }
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self else { return }
            self.notificationManager.cancelNotification(for: self.event.eventId)
        }
    }
    
    
    func cancelNotificationsForCourse() -> Void {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            self.isNotificationSetForCourse = false
            self.isNotificationSetForEvent = false
        }
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self else { return }
            if let course = self.event.course {
                self.notificationManager.cancelNotifications(with: course.courseId)
            }
        }
    }
    
    
    func scheduleNotificationForEvent() -> Void {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self else { return }
            let userOffset: Int = self.preferenceService.getNotificationOffset()
            
            // Create notification for event without categoryIdentifier,
            // since it does not need to be set for the entire course
            let notification = EventNotification(
                id: self.event.eventId,
                color: self.color.toHex() ?? "#FFFFFF",
                dateComponents: self.event.dateComponents!,
                categoryIdentifier: nil,
                content: self.event.toDictionary())
            
            self.notificationManager.scheduleNotification(
                for: notification,
                type: .event,
                userOffset: userOffset,
                completion: { result in
                    switch result {
                    case .success:
                        DispatchQueue.main.async {
                            self.isNotificationSetForEvent = true
                        }
                    case .failure(let failure):
                        AppLogger.shared.critical("Failed to schedule notifications -> \(failure)")
                        // TODO: Handle error in view
                    }
            })
        }
    }

    
    
    func scheduleNotificationsForCourse() -> Void {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self else { return }
            self.applyNotificationForScheduleEventsInCourse(schedules: self.schedules) { success in
                if success {
                    DispatchQueue.main.async {
                        self.isNotificationSetForCourse = true
                        self.isNotificationSetForEvent = true
                    }
                }
            }
        }
    }
    
    func userAllowedNotifications(completion: @escaping (Bool) -> Void) -> Void {
        notificationManager.notificationsAreAllowed(completion: { result in
            switch result {
            case .success:
                completion(true)
            case .failure:
                completion(false)
            }
        })
    }
}
