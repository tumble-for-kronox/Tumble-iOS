//
//  SidebarViewModel.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 2023-02-08.
//

import Foundation
import SwiftUI
import Combine

@MainActor final class SettingsViewModel: ObservableObject {
    
    @Inject var preferenceService: PreferenceService
    @Inject var scheduleService: ScheduleService
    @Inject var courseColorService: CourseColorService
    @Inject var notificationManager: NotificationManager
    @Inject var userController: UserController
    @Inject var schoolManager: SchoolManager
    
    @Published var universityName: String?
    @Published var bookmarks: [Bookmark]?
    @Published var schedules: [ScheduleData] = []
    @Published var courseColors: CourseAndColorDict = [:]
    @Published var presentSidebarSheet: Bool = false
    @Published var authStatus: AuthStatus = .unAuthorized
    
    lazy var schools: [School] = schoolManager.getSchools()
    var cancellables = Set<AnyCancellable>()
    
    init() {
        initialisePipelines()
        loadData()
        universityName = preferenceService.getUniversityName(schools: schools)
    }
    
    func initialisePipelines() -> Void {
        // Set up publisher to update schedules when data stores are updated
        // Always filter all received schedules through bookmarks
        preferenceService.$bookmarks
            .assign(to: \.bookmarks, on: self)
            .store(in: &cancellables)
        scheduleService.$schedules
            .assign(to: \.schedules, on: self)
            .store(in: &cancellables)
        courseColorService.$courseColors
            .assign(to: \.courseColors, on: self)
            .store(in: &cancellables)
        userController.$authStatus
            .assign(to: \.authStatus, on: self)
            .store(in: &cancellables)
    }
    
    func loadData() -> Void {
        schedules = scheduleService.getSchedules()
        bookmarks = preferenceService.getBookmarks()
        courseColors = courseColorService.getCourseColors()
    }
    
    func logOut() -> Void {
        userController.logOut(completion: { success in
            if success {
                AppLogger.shared.debug("Logged out")
                AppController.shared.toast = Toast(
                    type: .success,
                    title: NSLocalizedString("Logged out", comment: ""),
                    message: NSLocalizedString("You have successfully logged out of your account", comment: ""))
            } else {
                AppLogger.shared.debug("Could not log out")
                AppController.shared.toast = Toast(
                    type: .success,
                    title: NSLocalizedString("Error", comment: ""),
                    message: NSLocalizedString("Could not log out from your account", comment: ""))
            }
        })
    }
    
    func toggleBookmarkVisibility(for bookmark: String, to value: Bool) -> Void {
        preferenceService.toggleBookmark(bookmark: bookmark, value: value)
    }
    
    func deleteBookmark(id: String) -> Void {
        let oldSchedules = schedules
        scheduleService.remove(scheduleId: id, completion: { [weak self] result in
            guard let self else { return }
            switch result {
            case .success:
                // TODO: Show toast
                self.updateBookmarksRemoveNotifications(for: id, referencing: oldSchedules)
            case .failure(let failure):
                AppLogger.shared.error("\(failure)")
                // Failed to delete schedule
                // TODO: show toast
                return
            }
        })
    }
    
    private func updateBookmarksRemoveNotifications(for id: String, referencing oldSchedules: [ScheduleData]) -> Void {
        preferenceService.removeBookmark(id: id)
        let notificationIdsToRemove = oldSchedules.filter { $0.id == id }
        let events = notificationIdsToRemove
            .flatMap { $0.days }
            .flatMap { $0.events }
        events.forEach { notificationManager.cancelNotification(for: $0.id) }
    }
    
    func clearAllNotifications() -> Void {
        self.notificationManager.cancelNotifications()
    }
    
    func rescheduleNotifications(previousOffset: Int, newOffset: Int) -> Void {
        notificationManager.rescheduleEventNotifications(previousOffset: previousOffset, userOffset: newOffset)
    }
    
    func scheduleNotificationsForAllEvents(completion: @escaping (Result<Void, Error>) -> Void) -> Void {
        if schedules.isEmpty {
            completion(.failure(.generic(reason: "No schedules saved")))
            return
        }
        let hiddenBookmarks = preferenceService.getHiddenBookmarks()
        let allEvents = filterHiddenBookmarks(
            schedules: schedules,
            hiddenBookmarks: hiddenBookmarks).flatMap { $0.days.flatMap { $0.events } }
        for event in allEvents {
            guard let notification = self.notificationManager.createNotificationFromEvent(
                event: event,
                color: courseColors[event.course.id] ?? "#FEFEFE"
            ) else {
                AppLogger.shared.critical("Could not set notification for event \(event.id)")
                completion(.failure(.generic(reason: "Failed to set notification continuously")))
                break
            }
            self.notificationManager.scheduleNotification(
                for: notification, type: .event,
                userOffset: self.preferenceService.getNotificationOffset(),
                completion: { (result: Result<Int, NotificationError>) in
                    switch result {
                    case .success(let success):
                        AppLogger.shared.debug("\(success) notification set")
                    case .failure(let failure):
                        AppLogger.shared.critical("\(failure)")
                    }
                })
        }
        completion(.success(()))
    }
    
    func changeSchool(schoolId: Int) -> Void {
        self.userController.logOut()
        self.preferenceService.setSchool(id: schoolId)
        self.notificationManager.cancelNotifications()
        self.universityName = self.preferenceService.getUniversityName(schools: self.schools)
        scheduleService.removeAll(completion: { [weak self] result in
            guard let self else { return }
            switch result {
            case .success:
                self.courseColorService.removeAll(completion: { result in
                    switch result {
                    case .success:
                        AppLogger.shared.debug("Removed all stored schedules")
                    case .failure:
                        AppLogger.shared.error("Could not remove course colors when changing schools")
                    }
                })
            case .failure:
                AppLogger.shared.error("Could not remove schedules when changing schools")
            }
        })
    }
    
}

