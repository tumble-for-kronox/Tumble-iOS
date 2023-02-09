//
//  SidebarViewModel.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 2023-02-08.
//

import Foundation
import SwiftUI

extension SidebarMenu {
    @MainActor final class SidebarViewModel: ObservableObject {
        
        @Inject var preferenceService: PreferenceService
        @Inject var scheduleService: ScheduleService
        
        @Published var universityImage: Image?
        @Published var universityName: String?
        @Published var bookmarks: [Bookmark]?
        
        
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
            self.scheduleService.load() { [weak self] result in
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
            }
        }
        
        func toggleBookmarkVisibility(for bookmark: String, to value: Bool) -> Void {
            preferenceService.toggleBookmark(bookmark: bookmark, value: value)
        }
        
        func deleteBookmark(id: String) -> Void {
            var bookmarks = self.preferenceService.getBookmarks() ?? []
            bookmarks.removeAll(where: { $0.id == id })
            preferenceService.setBookmarks(bookmarks: bookmarks)
            self.bookmarks = bookmarks
        }
    }
}


extension SidebarMenu.SidebarViewModel {
    
    fileprivate func missingIDs(scheduleModels: [ScheduleStoreModel], bookmarks: [Bookmark]) -> [String] {
        let scheduleIDs = Set(scheduleModels.map { $0.id })
        let bookmarkIDs = Set(bookmarks.map { $0.id })
        return Array(bookmarkIDs.subtracting(scheduleIDs))
    }

    fileprivate func removeMissingIDs(bookmarks: [Bookmark], missingIDs: [String]) -> [Bookmark] {
        return bookmarks.filter { !missingIDs.contains($0.id) }
    }
}
