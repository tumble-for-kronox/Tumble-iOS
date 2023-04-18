//
//  ParentViewModel.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 11/16/22.
//

import Foundation
import SwiftUI
import Combine
import RealmSwift

// Parent/Container for other viewmodels
final class ParentViewModel: ObservableObject {
    
    var viewModelFactory: ViewModelFactory = ViewModelFactory.shared
    
    @Inject var preferenceService: PreferenceService
    @Inject var kronoxManager: KronoxManager
    
    lazy var homeViewModel: HomeViewModel = viewModelFactory.makeViewModelHome()
    lazy var bookmarksViewModel: BookmarksViewModel = viewModelFactory.makeViewModelBookmarks()
    lazy var accountPageViewModel: AccountViewModel = viewModelFactory.makeViewModelAccount()
    lazy var searchViewModel: SearchViewModel = viewModelFactory.makeViewModelSearch()
    lazy var settingsViewModel: SettingsViewModel = viewModelFactory.makeViewModelSettings()
        
    private var updatedDuringSession: Bool = false
    
    
    func updateBookmarks() -> Void {
        // Get all stored shedule id's from preferences
        DispatchQueue.global(qos: .background).async { [weak self] in
            guard let self else { return }
            defer { self.updatedDuringSession = true } // Always claim update during startup, even if failed
            let bookmarks: [Bookmark]? = self.preferenceService.getBookmarks()
            let schoolId: Int? = self.preferenceService.getDefaultSchool()
            if let bookmarks = bookmarks, let schoolId = schoolId {
                for bookmark in bookmarks {
                    let scheduleId: String = bookmark.id
                    let endpoint: Endpoint = .schedule(scheduleId: scheduleId, schoolId: String(schoolId))
                    // Fetch schedule from backend
                    let _ = self.kronoxManager.get(
                        endpoint, then: { (result: Result<Response.Schedule, Response.ErrorMessage>) in
                            switch result {
                            case .success(let fetchedSchedule):
                                AppLogger.shared.info("Updated schedule with id: \(fetchedSchedule.id)")
                                DispatchQueue.main.async {
                                    self.saveSchedule(schedule: fetchedSchedule)
                                }
                            case .failure(let failure):
                                AppLogger.shared.info("Updating could not finish due to network error: \(failure)")
                            }
                    })
                }
            } else {
                AppLogger.shared.info("No bookmarks or school id available")
            }
        }
    }
    
    func saveSchedule(schedule: Response.Schedule) {
        let realmSchedule: Schedule = schedule.toRealmSchedule()
        let realm = try! Realm()
        try? realm.write {
            realm.add(realmSchedule, update: .modified)
        }
    }

}
