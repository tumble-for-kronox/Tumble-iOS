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
    @Inject var userController: UserController
    @Inject var schoolManager: SchoolManager
    @Inject var realmManager: RealmManager
    
    @Published var bookmarks: [Bookmark]?
    @Published var presentSidebarSheet: Bool = false
    @Published var authStatus: AuthStatus = .unAuthorized
    @Published var authSchoolId: Int = -1
    @Published var schoolName: String = ""
    
    let popupFactory: PopupFactory = PopupFactory.shared
    lazy var schools: [School] = schoolManager.getSchools()
    var cancellables = Set<AnyCancellable>()
    
    init() { setUpDataPublishers() }
    
    private func setUpDataPublishers() {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self else { return }
            let authStatusPublisher = self.userController.$authStatus
            let schoolIdPublisher = self.preferenceService.$authSchoolId
            
            Publishers.CombineLatest(
                schoolIdPublisher,
                authStatusPublisher
            )
            .receive(on: RunLoop.main)
            .sink { schoolId, authStatus in
                self.authStatus = authStatus
                self.authSchoolId = schoolId
                self.schoolName = self.schoolManager.getSchools().first(where: { $0.id == schoolId })?.name ?? ""
            }
            .store(in: &self.cancellables)
        }
    }
    
    func logOut() {
        Task {
            do {
                try await userController.logOut()
                DispatchQueue.main.async { [weak self] in
                    AppController.shared.popup = self?.popupFactory.logOutSuccess()
                }
            } catch {
                DispatchQueue.main.async { [weak self] in
                    AppController.shared.popup = self?.popupFactory.logOutFailed()
                }
            }
        }
    }
    
    func removeNotificationsFor(for id: String, referencing events: [Event]) {
        events.forEach { notificationManager.cancelNotification(for: $0.eventId) }
    }
    
    func clearAllNotifications() {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self else { return }
            self.notificationManager.cancelNotifications()
        }
        AppController.shared.popup = popupFactory.clearNotificationsAllEventsSuccess()
    }
    
    func rescheduleNotifications(previousOffset: Int, newOffset: Int) {
        Task {
            do {
                try await notificationManager.rescheduleEventNotifications(
                    previousOffset: previousOffset,
                    userOffset: newOffset
                )
            } catch {
                // TODO: Error handling
            }
        }
    }
    
    func scheduleNotificationsForAllEvents(allEvents: [Event]) async {
        guard !allEvents.isEmpty else {
            AppController.shared.popup = popupFactory.setNotificationsAllEventsFailed()
            return
        }
        
        let totalNotifications = allEvents.count
        var scheduledNotifications = 0
        
        for event in allEvents {
            guard let notification = notificationManager.createNotificationFromEvent(
                event: event
            ) else {
                AppLogger.shared.critical("Could not set notification for event \(event._id)")
                AppController.shared.popup = popupFactory.setNotificationsAllEventsFailed()
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
                        AppController.shared.popup = self?.popupFactory.setNotificationsAllEventsSuccess()
                    }
                }
            } catch let failure {
                AppLogger.shared.critical("\(failure)")
                // TODO: Error handling
            }
        }
    }

    
    func deleteBookmark(schedule: Schedule) {
        realmManager.deleteSchedule(schedule: schedule)
    }
    
    private func deleteAllSchedules() {
        realmManager.deleteAllSchedules()
    }
}
