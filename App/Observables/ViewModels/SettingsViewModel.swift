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
    @Inject var preferenceManager: PreferenceManager
    @Inject var notificationManager: NotificationManager
    @Inject var schoolManager: SchoolManager
    @Inject var realmManager: RealmManager
    
    @Published var bookmarks: [Bookmark]?
    @Published var presentSidebarSheet: Bool = false
    @Published var authStatus: AuthStatus = .unAuthorized
    @Published var authSchoolId: Int = -1
    @Published var appearance: String = AppearanceTypes.system.rawValue
    @Published var notificationOffset: Int = 60
    @Published var schoolName: String = ""
    
    let popupFactory: PopupFactory = PopupFactory.shared
    private lazy var schools: [School] = schoolManager.getSchools()
    private var cancellables: Set<AnyCancellable> = []
    
    init() { setUpDataPublishers() }
    
    private func setUpDataPublishers() {
        
        let authSchoolIdPublisher = preferenceManager.$authSchoolId.receive(on: RunLoop.main)
        let appearancePublisher = preferenceManager.$appearance.receive(on: RunLoop.main)
        let notificationOffsetPublisher = preferenceManager.$notificationOffset.receive(on: RunLoop.main)
        
        Publishers.CombineLatest3(authSchoolIdPublisher, appearancePublisher, notificationOffsetPublisher)
            .sink { [weak self] authSchoolId, appearance, notificationOffset in
                self?.authSchoolId = authSchoolId
                self?.notificationOffset = notificationOffset
                self?.appearance = appearance
                self?.schoolName = self?.schools.first(where: { $0.id == authSchoolId })?.name ?? ""
                
            }
            .store(in: &cancellables)
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
                AppLogger.shared.error("Could not reschedule notifications")
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
                AppLogger.shared.error("Could not set notification for event \(event._id)")
                PopupToast(popup: popupFactory.setNotificationsAllEventsFailed()).showAndStack()
                return
            }
            
            do {
                try await notificationManager.scheduleNotification(
                    for: notification,
                    type: .event,
                    userOffset: preferenceManager.notificationOffset
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
                AppLogger.shared.error("\(failure)")
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
        cancellables.forEach { $0.cancel() }
    }

}
