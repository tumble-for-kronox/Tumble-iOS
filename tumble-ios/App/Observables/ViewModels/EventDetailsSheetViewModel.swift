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
    @Inject var scheduleService: ScheduleService
    @Inject var courseColorService: CourseColorService
    
    @Published var event: Response.Event
    @Published var color: Color
    @Published var isNotificationSetForEvent: Bool = false
    @Published var isNotificationSetForCourse: Bool = false
    @Published var notificationOffset: Int = 60
    @Published var notificationsAllowed: Bool = false
    @Published var schedules: [ScheduleData] = []
    
    private var cancellables = Set<AnyCancellable>()
    
    init(event: Response.Event, color: Color) {
        self.event = event
        self.color = color
        setUpDataPublishers()
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
    
    func setUpDataPublishers() -> Void {
        scheduleService.$schedules
            .assign(to: \.schedules, on: self)
            .store(in: &cancellables)
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
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            self.event = event
            self.color = color
        }
    }
    
    
    func cancelNotificationForEvent() -> Void {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            isNotificationSetForEvent = false
        }
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self else { return }
            notificationManager.cancelNotification(for: event.id)
        }
    }
    
    
    func cancelNotificationsForCourse() -> Void {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            isNotificationSetForCourse = false
            isNotificationSetForEvent = false
        }
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self else { return }
            notificationManager.cancelNotifications(with: event.course.id)
        }
    }
    
    
    func scheduleNotificationForEvent() -> Void {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self else { return }
            let userOffset: Int = self.preferenceService.getNotificationOffset()
            
            // Create notification for event without categoryIdentifier,
            // since it does not need to be set for the entire course
            let notification = EventNotification(
                id: self.event.id,
                color: self.color.toHex() ?? "#FFFFFF",
                dateComponents: self.event.dateComponents!,
                categoryIdentifier: nil,
                content: self.event.toDictionary())
            
            notificationManager.scheduleNotification(
                for: notification,
                type: .event,
                userOffset: userOffset,
                completion: { result in
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
    }

    
    
    func scheduleNotificationsForCourse() -> Void {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self else { return }
            applyNotificationForScheduleEventsInCourse(schedules: schedules) { success in
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
