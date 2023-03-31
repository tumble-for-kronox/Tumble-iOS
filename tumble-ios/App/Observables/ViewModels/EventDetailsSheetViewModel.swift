//
//  EventDetailsView-ViewModel.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 2023-02-01.
//

import Foundation
import SwiftUI

@MainActor final class EventDetailsSheetViewModel: ObservableObject {
    
    @Inject var notificationManager: NotificationManager
    @Inject var preferenceService: PreferenceService
    @Inject var scheduleService: ScheduleService
    @Inject var courseColorService: CourseColorService
    
    @Published var event: Response.Event
    @Published var color: Color {
        didSet {
            replaceColor()
        }
    }
    @Published var isNotificationSetForEvent: Bool = false
    @Published var isNotificationSetForCourse: Bool = false
    @Published var notificationOffset: Int = 60
    @Published var notificationsAllowed: Bool = false
    
    
    init(event: Response.Event, color: Color) {
        self.event = event
        self.color = color
        self.checkNotificationIsSetForEvent()
        self.checkNotificationIsSetForCourse()
        self.notificationOffset = preferenceService.getNotificationOffset()
        self.userAllowedNotifications(completion: { value in
            DispatchQueue.main.async {
                self.notificationsAllowed = value
            }
        })
    }
    
    func replaceColor() -> Void {
        courseColorService.replace(for: event, with: color) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(_):
                AppLogger.shared.debug("Changed course color for -> \(self.event.course.id) to color -> \(self.color.toHex() ?? "#FFFFFF")")
            case .failure(let failure):
                AppLogger.shared.debug("Couldn't change course color -> \(failure)")
            }
        }
    }
    
    func setEventSheetView(event: Response.Event, color: Color) -> Void {
        self.event = event
        self.color = color
    }
    
    
    func cancelNotificationForEvent() -> Void {
        notificationManager.cancelNotification(for: event.id)
        self.isNotificationSetForEvent = false
    }
    
    
    func cancelNotificationsForCourse() -> Void {
        notificationManager.cancelNotifications(with: event.course.id)
        self.isNotificationSetForCourse = false
        self.isNotificationSetForEvent = false
    }
    
    
    func scheduleNotificationForEvent() -> Void {
        let userOffset: Int = self.preferenceService.getNotificationOffset()
        
        // Create notification for event without categoryIdentifier,
        // since it does not need to be set for the entire course
        let notification = EventNotification(
            id: self.event.id,
            color: self.color.toHex() ?? "#FFFFFF",
            dateComponents: self.event.dateComponents!,
            categoryIdentifier: nil,
            content: self.event.toDictionary())
        
        self.notificationManager.scheduleNotification(
            for: notification,
            type: .event,
            userOffset: userOffset,
            completion: { [weak self] result in
                guard let self = self else { return }
                switch result {
                case .success(_):
                    DispatchQueue.main.async {
                        self.isNotificationSetForEvent = true
                    }
                case .failure(let failure):
                    AppLogger.shared.critical("Failed to schedule notifications -> \(failure)")
                    // TODO: Handle error in view
                }
        })
    }

    
    
    func scheduleNotificationsForCourse() -> Void {
        scheduleService.load(completion: { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let success):
                let schedules = success
                self.applyNotificationForScheduleEventsInCourse(schedules: schedules) { success in
                    if success {
                        DispatchQueue.main.async {
                            self.isNotificationSetForCourse = true
                            self.isNotificationSetForEvent = true
                        }
                    }
                }
            case .failure(let failure):
                AppLogger.shared.debug("\(failure)")
            }
        })
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
