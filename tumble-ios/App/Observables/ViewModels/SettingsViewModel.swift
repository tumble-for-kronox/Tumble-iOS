//
//  SidebarViewModel.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 2023-02-08.
//

import Foundation
import SwiftUI

@MainActor final class SettingsViewModel: ObservableObject {
    
    @Inject private var preferenceService: PreferenceService
    @Inject private var scheduleService: ScheduleService
    @Inject private var courseColorService: CourseColorService
    @Inject private var notificationManager: NotificationManager
    @Inject private var userController: UserController
    
    @Published var universityImage: Image?
    @Published var universityName: String?
    @Published var bookmarks: [Bookmark]?
    @Published var presentSidebarSheet: Bool = false
    
    
    init() {
        self.universityImage = self.preferenceService.getUniversityImage()
        self.universityName = self.preferenceService.getUniversityName()
        self.bookmarks = preferenceService.getBookmarks() ?? []
    }
    
    func updateViewLocals() -> Void {
        self.universityImage = self.preferenceService.getUniversityImage()
        self.universityName = self.preferenceService.getUniversityName()
        self.updateBookmarks()
    }
    
    func updateBookmarks() -> Void {
        self.scheduleService.load(completion: { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let schedules):
                
                // Get current bookmarks in preferences
                var bookmarks = self.preferenceService.getBookmarks() ?? []
                
                // Find the one's that aren't supposed to be there
                let missingIds = self.missingIDs(scheduleModels: schedules, bookmarks: bookmarks)
                
                // Remove the missing id's
                bookmarks = self.removeMissingIDs(bookmarks: bookmarks, missingIDs: missingIds)
                
                self.preferenceService.setBookmarks(bookmarks: bookmarks)
                
                DispatchQueue.main.async {
                    self.bookmarks = bookmarks
                }
                
            case .failure(let failure):
                AppLogger.shared.info("\(failure)")
            }
            
        })
    }

    
    func toggleBookmarkVisibility(for bookmark: String, to value: Bool) -> Void {
        preferenceService.toggleBookmark(bookmark: bookmark, value: value)
    }
    
    func deleteBookmark(id: String) -> Void {
        var preferenceBookmarks = self.preferenceService.getBookmarks() ?? []
        preferenceBookmarks.removeAll(where: { $0.id == id })
        preferenceService.setBookmarks(bookmarks: preferenceBookmarks)
        self.loadSchedules { schedules in
            let schedulesToRemove = schedules.filter { $0.id == id }
            let events = schedulesToRemove
                .flatMap { schedule in schedule.days }
                .flatMap { day in day.events }
            events.forEach { event in self.notificationManager.cancelNotification(for: event.id) }
        }
        DispatchQueue.main.async {
            self.bookmarks = preferenceBookmarks
        }
    }
    
    func clearAllNotifications() -> Void {
        self.notificationManager.cancelNotifications()
    }
    
    func rescheduleNotifications(previousOffset: Int, newOffset: Int) -> Void {
        notificationManager.rescheduleEventNotifications(previousOffset: previousOffset, userOffset: newOffset)
    }
    
    func scheduleNotificationsForAllEvents(completion: @escaping (Result<Void, Error>) -> Void) -> Void {
        self.scheduleService.load(completion: { [weak self] (result: Result<[ScheduleStoreModel], Error>) in
            guard let self = self else { return }
            switch result {
            case .success(let schedules):
                self.courseColorService.load { (result: Result<CourseAndColorDict, Error>) in
                    switch result {
                    case .success(let courseColorsDict):
                        let allEvents = schedules.flatMap { $0.days.flatMap { $0.events } }
                        for event in allEvents {
                            guard let notification = self.notificationManager.createNotificationFromEvent(
                                event: event,
                                color: courseColorsDict[event.course.id] ?? "#FEFEFE"
                            ) else {
                                AppLogger.shared.info("Could not set notification for event \(event.id)")
                                completion(.failure(.generic(reason: "Failed to set notification continuously")))
                                break
                            }
                            self.notificationManager.scheduleNotification(
                                for: notification, type: .event,
                                userOffset: self.preferenceService.getNotificationOffset(),
                                completion: { (result: Result<Int, NotificationError>) in
                                    switch result {
                                    case .success(let success):
                                        AppLogger.shared.info("\(success) notification set")
                                    case .failure(let failure):
                                        AppLogger.shared.info("\(failure)")
                                    }
                                })
                        }
                        completion(.success(()))
                    case .failure(let failure):
                        AppLogger.shared.info("Colors could not be loaded from local storage: \(failure)")
                        completion(.failure(.internal(reason: "Failed to load course colors")))
                    }
                }
            case .failure:
                AppLogger.shared.info("Schedules could not be loaded from local storage")
                completion(.failure(.internal(reason: "Failed to load schedules")))
            }
        })
    }

    
}

extension SettingsViewModel {
    
    fileprivate func loadSchedules(completion: @escaping ([ScheduleStoreModel]) -> Void) -> Void {
        self.scheduleService.load(completion: {result in
            switch result {
            case .failure(_):
                return
            case .success(let bookmarks):
                DispatchQueue.main.async {
                    completion(bookmarks)
                }
            }
        })
    }
    
    fileprivate func missingIDs(scheduleModels: [ScheduleStoreModel], bookmarks: [Bookmark]) -> [String] {
        let scheduleIDs = Set(scheduleModels.map { $0.id })
        let bookmarkIDs = Set(bookmarks.map { $0.id })
        return Array(bookmarkIDs.subtracting(scheduleIDs))
    }

    fileprivate func removeMissingIDs(bookmarks: [Bookmark], missingIDs: [String]) -> [Bookmark] {
        return bookmarks.filter { !missingIDs.contains($0.id) }
    }
}
