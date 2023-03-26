//
//  SidebarViewModel.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 2023-02-08.
//

import Foundation
import SwiftUI

@MainActor final class SidebarViewModel: ObservableObject {
    
    @Inject var preferenceService: PreferenceService
    @Inject var scheduleService: ScheduleService
    @Inject var courseColorService: CourseColorService
    @Inject var notificationManager: NotificationManager
    @Inject var userController: UserController
    
    @Published var universityImage: Image?
    @Published var universityName: String?
    @Published var bookmarks: [Bookmark]?
    @Published var sidebarSheetType: SidebarTabType? = nil
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
                
                self.bookmarks = bookmarks
                
            case .failure(let failure):
                AppLogger.shared.info("\(failure)")
            }
            
        })
    }

    
    func toggleBookmarkVisibility(for bookmark: String, to value: Bool) -> Void {
        preferenceService.toggleBookmark(bookmark: bookmark, value: value)
    }
    
    func deleteBookmark(id: String) -> Void {
        var bookmarks = self.preferenceService.getBookmarks() ?? []
        bookmarks.removeAll(where: { $0.id == id })
        preferenceService.setBookmarks(bookmarks: bookmarks)
        self.loadSchedules { schedules in
            let schedulesToRemove = schedules.filter { $0.id == id }
            let events = schedulesToRemove
                .flatMap { schedule in schedule.days }
                .flatMap { day in day.events }
            events.forEach { event in self.notificationManager.cancelNotification(for: event.id) }
        }
        self.bookmarks = bookmarks
    }
    
    func clearAllNotifications() -> Void {
        self.notificationManager.cancelNotifications()
    }
    
    func scheduleNotificationsForAllCourses() -> Void {
        self.scheduleService.load(completion: { [weak self] (result: Result<[ScheduleStoreModel], Error>) in
            guard let self = self else { return }
            switch result {
            case .success(let schedules):
                self.courseColorService.load { (result: Result<CourseAndColorDict, Error>) in
                    switch result {
                    case .success(let courseColorsDict):
                        let allEvents = schedules.flatMap { $0.days.flatMap { $0.events } }
                        for event in allEvents {
                            self.notificationManager.scheduleNotification(
                                for: self.notificationManager.createNotificationFromEvent(
                                    event: event,
                                    color: courseColorsDict[event.course.id] ?? "#FEFEFE"
                                ), type: .event,
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
                    case .failure(let failure):
                        AppLogger.shared.info("Colors could not be loaded from local storage: \(failure)")
                    }
                }
            case .failure:
                AppLogger.shared.info("Schedules could not be loaded from local storage")
            }
        })
    }

    
}

extension SidebarViewModel {
    
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
