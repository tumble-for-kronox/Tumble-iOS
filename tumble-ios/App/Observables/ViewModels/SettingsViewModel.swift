//
//  SidebarViewModel.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 2023-02-08.
//

import Foundation
import SwiftUI
import Combine

final class SettingsViewModel: ObservableObject {
    
    @Inject var preferenceService: PreferenceService
    @Inject var scheduleService: ScheduleService
    @Inject var courseColorService: CourseColorService
    @Inject var notificationManager: NotificationManager
    @Inject var userController: UserController
    @Inject var schoolManager: SchoolManager
    
    @Published var bookmarks: [Bookmark]?
    @Published var schedules: [ScheduleData] = []
    @Published var courseColors: CourseAndColorDict = [:]
    @Published var presentSidebarSheet: Bool = false
    @Published var authStatus: AuthStatus = .unAuthorized
    @Published var schoolId: Int = -1
    @Published var schoolName: String = ""
    
    lazy var schools: [School] = schoolManager.getSchools()
    var cancellables = Set<AnyCancellable>()
    
    
    init() {
        setUpDataPublishers()
    }
    
    private func setUpDataPublishers() -> Void {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self else { return }
            let bookmarksPublisher = preferenceService.$bookmarks.receive(on: DispatchQueue.main)
            let schedulesPublisher = scheduleService.$schedules.receive(on: DispatchQueue.main)
            let courseColorsPublisher = courseColorService.$courseColors.receive(on: DispatchQueue.main)
            let authStatusPublisher = userController.$authStatus.receive(on: DispatchQueue.main)
            let schoolIdPublisher = preferenceService.$schoolId.receive(on: DispatchQueue.main)
            
            schoolIdPublisher
                .sink { schoolId in
                    self.schoolId = schoolId
                    self.schoolName = self.schoolManager.getSchools().first(where: { $0.id == schoolId })?.name ?? ""
                }
                .store(in: &cancellables)
            
            Publishers.CombineLatest4(
                bookmarksPublisher,
                schedulesPublisher,
                courseColorsPublisher,
                authStatusPublisher
            )
            .sink { bookmarks, schedules, courseColors, authStatus in
                self.bookmarks = bookmarks
                self.schedules = schedules
                self.courseColors = courseColors
                self.authStatus = authStatus
            }
            .store(in: &cancellables)
        }
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
                DispatchQueue.global(qos: .userInitiated).async {
                    self.updateBookmarksRemoveNotifications(for: id, referencing: oldSchedules)
                }
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
        notificationManager.cancelNotifications()
        makeToast(
            type: .success,
            title: NSLocalizedString("Cancelled notifications", comment: ""),
            message: NSLocalizedString("Cancelled all available notifications set for events", comment: "")
        )
    }
    
    func rescheduleNotifications(previousOffset: Int, newOffset: Int) -> Void {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self else { return }
            self.notificationManager.rescheduleEventNotifications(
                previousOffset: previousOffset,
                userOffset: newOffset
            )
        }
    }
    
    func scheduleNotificationsForAllEvents() {
        guard !schedules.isEmpty else {
            makeToast(
                type: .error,
                title: NSLocalizedString("Error", comment: ""),
                message: NSLocalizedString("Failed to set notifications for all available events", comment: "")
            )
            return
        }
        
        let hiddenBookmarks = preferenceService.getHiddenBookmarks()
        let allEvents = filterHiddenBookmarks(
            schedules: schedules,
            hiddenBookmarks: hiddenBookmarks
        )
        .flatMap { $0.days.flatMap { $0.events } }
        
        let totalNotifications = allEvents.count
        var scheduledNotifications = 0
        
        for event in allEvents {
            guard let notification = notificationManager.createNotificationFromEvent(
                event: event,
                color: courseColors[event.course.id] ?? "#FEFEFE"
            ) else {
                AppLogger.shared.critical("Could not set notification for event \(event.id)")
                makeToast(
                    type: .error,
                    title: NSLocalizedString("Error", comment: ""),
                    message: NSLocalizedString("Failed to set notifications for all available events", comment: "")
                )
                break
            }
            
            notificationManager.scheduleNotification(
                for: notification,
                type: .event,
                userOffset: preferenceService.getNotificationOffset()
            ) { [weak self] result in
                guard let self else { return }
                switch result {
                case .success(let success):
                    scheduledNotifications += 1
                    AppLogger.shared.debug("\(success) notification set")
                    
                    if scheduledNotifications == totalNotifications {
                        self.makeToast(
                            type: .success,
                            title: NSLocalizedString("Scheduled notifications", comment: ""),
                            message: NSLocalizedString("Scheduled notifications for all available events", comment: "")
                        )
                    }
                    
                case .failure(let failure):
                    AppLogger.shared.critical("\(failure)")
                }
            }
        }
    }
    
    func changeSchool(schoolId: Int) -> Void {
        if schoolIsAlreadySelected(schoolId: schoolId) {
            return
        }
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self else { return }
            userController.logOut()
            preferenceService.setSchool(id: schoolId)
            notificationManager.cancelNotifications()
            preferenceService.removeAllBookmarks()
        }
        scheduleService.removeAll(completion: { [weak self] result in
            guard let self else { return }
            switch result {
            case .success:
                self.courseColorService.removeAll(completion: { result in
                    switch result {
                    case .success:
                        AppLogger.shared.debug("Removed all stored schedules")
                        self.makeToast(
                            type: .success,
                            title: NSLocalizedString("New school", comment: ""),
                            message: String(
                                format: NSLocalizedString("Set %@ to default", comment: ""),
                                self.schoolName
                            ))
                    case .failure:
                        AppLogger.shared.error("Could not remove course colors when changing schools")
                        self.makeToast(
                            type: .success,
                            title: NSLocalizedString("Error", comment: ""),
                            message: String(
                                format: NSLocalizedString("Something went wrong", comment: "")
                            ))
                    }
                })
            case .failure:
                AppLogger.shared.error("Could not remove schedules when changing schools")
            }
        })
    }
    
    func makeToast(type: ToastStyle, title: String, message: String) -> Void {
        DispatchQueue.main.async {
            AppController.shared.toast = Toast(
                type: type,
                title: title,
                message: message)
        }
    }
    
    private func schoolIsAlreadySelected(schoolId: Int) -> Bool {
        if schoolId == self.schoolId {
            makeToast(
                type: .info,
                title: NSLocalizedString("School already selected", comment: ""),
                message: String(
                    format: NSLocalizedString("You already have '%@' as your default school", comment: ""),
                    schoolName
                ))
            return true
        }
        return false
    }
    
}

