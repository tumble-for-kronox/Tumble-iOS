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
    
    @Published var event: Event
    @Published var color: Color
    @Published var isNotificationSetForEvent: Bool = false
    @Published var isNotificationSetForCourse: Bool = false
    @Published var notificationOffset: Int = 60
    @Published var notificationsAllowed: Bool = false
        
    init(event: Event) {
        self.event = event
        color = event.course?.color.toColor() ?? .white
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
            notificationManager.cancelNotifications(with: course.courseId)
        }
    }
    
    @MainActor func scheduleNotificationForEvent() {
        let userOffset: Int = preferenceService.getNotificationOffset()
        
        // Create notification for event without categoryIdentifier,
        // since it does not need to be set for the entire course
        let notification = EventNotification(
            id: event.eventId,
            dateComponents: event.dateComponents!,
            categoryIdentifier: nil,
            content: event.toDictionary()
        )
        
        notificationManager.scheduleNotification(
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
            }
        )
    }

    @MainActor func updateCourseColor() {
        guard let colorToSet = color.toHex(),
              let realm = try? Realm(),
              let eventCourseID = event.course?.courseId
        else {
            return
        }
        
        try! realm.write {
            let schedules = realm.objects(Schedule.self)
            for schedule in schedules {
                let eventsToUpdate = schedule.days
                    .flatMap { $0.events.filter { $0.course?.courseId == eventCourseID } }
                for event in eventsToUpdate {
                    if let courseToUpdate = event.course,
                       courseToUpdate.color != colorToSet
                    {
                        courseToUpdate.color = colorToSet
                    }
                }
            }
        }
    }

    @MainActor func scheduleNotificationsForCourse() {
        let realm = try! Realm()
        let schedules = realm.objects(Schedule.self)
        let events = Array(schedules)
            .flatMap { $0.days }
            .flatMap { $0.events }
            .filter { !($0.dateComponents!.hasDatePassed()) }
            .filter { $0.course?.courseId == event.course?.courseId }
        applyNotificationForScheduleEventsInCourse(events: events) { success in
            if success {
                self.isNotificationSetForCourse = true
                self.isNotificationSetForEvent = true
            }
        }
    }
    
    func userAllowedNotifications(completion: @escaping (Bool) -> Void) {
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
