//
//  SettingsViewModel.swift
//  Tumble
//
//  Created by Adis Veletanlic on 2023-02-08.
//

import Combine
import Foundation
import RealmSwift
import SwiftUI

final class SettingsViewModel: ObservableObject {
    @Inject var preferenceService: PreferenceService
    @Inject var notificationManager: NotificationManager
    @Inject var schoolManager: SchoolManager
    @Inject var realmManager: RealmManager
    
    @Published var bookmarks: [Bookmark]?
    @Published var presentSidebarSheet: Bool = false
    @Published var authStatus: AuthStatus = .unAuthorized
    @Published var authSchoolId: Int = -1
    @Published var schoolName: String = ""
    
    let popupFactory: PopupFactory = PopupFactory.shared
    private lazy var schools: [School] = schoolManager.getSchools()
    private var cancellable: AnyCancellable? = nil
    
    init() { setUpDataPublishers() }
    
    private func setUpDataPublishers() {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self else { return }
            let schoolIdPublisher = self.preferenceService.$authSchoolId.receive(on: RunLoop.main)
            
            self.cancellable = schoolIdPublisher.sink { schoolId in
                self.authSchoolId = schoolId
                self.schoolName = self.schools.first(where: { $0.id == schoolId })?.name ?? ""
            }
            
        }
    }
    
    func removeNotifications(for id: String, referencing events: [Event]) {
        events.forEach { notificationManager.cancelNotification(for: $0.eventId) }
    }
    
    func clearAllNotifications() {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self else { return }
            self.notificationManager.cancelNotifications()
        }
        PopupToast(popup: popupFactory.clearNotificationsAllEventsSuccess()).showAndStack()
    }
    
    func rescheduleNotifications(previousOffset: Int, newOffset: Int) {
        Task {
            do {
                try await notificationManager.rescheduleEventNotifications(
                    previousOffset: previousOffset,
                    userOffset: newOffset
                )
            } catch {
                // TODO: Show toast
            }
        }
    }
    
    func scheduleNotificationsForAllEvents(allEvents: [Event]) async {
        guard !allEvents.isEmpty else {
            PopupToast(popup: popupFactory.setNotificationsAllEventsFailed()).showAndStack()
            return
        }
        
        let totalNotifications = allEvents.count
        var scheduledNotifications = 0
        
        for event in allEvents {
            guard let notification = notificationManager.createNotificationFromEvent(
                event: event
            ) else {
                AppLogger.shared.critical("Could not set notification for event \(event._id)")
                PopupToast(popup: popupFactory.setNotificationsAllEventsFailed()).showAndStack()
                return
            }
            
            do {
                try await notificationManager.scheduleNotification(
                    for: notification,
                    type: .event,
                    userOffset: preferenceService.getNotificationOffset()
                )
                scheduledNotifications += 1
                AppLogger.shared.debug("One notification set")
                
                if scheduledNotifications == totalNotifications {
                    DispatchQueue.main.async { [weak self] in
                        guard let self else { return }
                        PopupToast(popup: self.popupFactory.setNotificationsAllEventsSuccess()).showAndStack()
                    }
                }
            } catch let failure {
                AppLogger.shared.critical("\(failure)")
                // TODO: Show toast
            }
        }
    }

    
    func deleteBookmark(schedule: Schedule) {
        realmManager.deleteSchedule(schedule: schedule)
    }
    
    private func deleteAllSchedules() {
        realmManager.deleteAllSchedules()
    }
    
    deinit {
        cancellable?.cancel()
    }

}
