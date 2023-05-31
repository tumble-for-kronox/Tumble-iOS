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
    
    let toastFactory: ToastFactory = ToastFactory.shared
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
                    AppController.shared.toast = self?.toastFactory.logOutSuccess()
                }
            } catch {
                DispatchQueue.main.async { [weak self] in
                    AppController.shared.toast = self?.toastFactory.logOutFailed()
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
        AppController.shared.toast = toastFactory.clearNotificationsAllEventsSuccess()
    }
    
    func rescheduleNotifications(previousOffset: Int, newOffset: Int) {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self else { return }
            self.notificationManager.rescheduleEventNotifications(
                previousOffset: previousOffset,
                userOffset: newOffset
            )
        }
    }
    
    func scheduleNotificationsForAllEvents(allEvents: [Event]) {
        guard !allEvents.isEmpty else {
            AppController.shared.toast = toastFactory.setNotificationsAllEventsFailed()
            return
        }
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self else { return }
            
            let totalNotifications = allEvents.count
            var scheduledNotifications = 0
            
            for event in allEvents {
                guard let notification = self.notificationManager.createNotificationFromEvent(
                    event: event
                ) else {
                    AppLogger.shared.critical("Could not set notification for event \(event._id)")
                    AppController.shared.toast = self.toastFactory.setNotificationsAllEventsFailed()
                    break
                }
                
                self.notificationManager.scheduleNotification(
                    for: notification,
                    type: .event,
                    userOffset: self.preferenceService.getNotificationOffset()
                ) { [weak self] result in
                    guard let self else { return }
                    switch result {
                    case .success(let success):
                        scheduledNotifications += 1
                        AppLogger.shared.debug("\(success) notification set")
                        
                        if scheduledNotifications == totalNotifications {
                            DispatchQueue.main.async {
                                AppController.shared.toast = self.toastFactory.setNotificationsAllEventsSuccess()
                            }
                        }
                    case .failure(let failure):
                        AppLogger.shared.critical("\(failure)")
                    }
                }
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
