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
    @ObservedResults(Schedule.self) var schedules
    
    lazy var homeViewModel: HomeViewModel = viewModelFactory.makeViewModelHome()
    lazy var bookmarksViewModel: BookmarksViewModel = viewModelFactory.makeViewModelBookmarks()
    lazy var accountPageViewModel: AccountViewModel = viewModelFactory.makeViewModelAccount()
    lazy var searchViewModel: SearchViewModel = viewModelFactory.makeViewModelSearch()
    lazy var settingsViewModel: SettingsViewModel = viewModelFactory.makeViewModelSettings()
        
    private var updatedDuringSession: Bool = false
    
    init() {
        updateBookmarks()
    }
    
    func updateBookmarks() -> Void {
        defer { self.updatedDuringSession = true } // Always claim update during startup, even if failed
        let schoolId: Int? = preferenceService.getDefaultSchool()
        
        if let schoolId = schoolId {
            for schedule in schedules {
                let scheduleId: String = schedule.scheduleId
                let endpoint: Endpoint = .schedule(scheduleId: scheduleId, schoolId: String(schoolId))
                // Fetch schedule from backend
                let _ = kronoxManager.get(
                    endpoint, then: { [weak self] (result: Result<Response.Schedule, Response.ErrorMessage>) in
                        guard let self else { return }
                        switch result {
                        case .success(let fetchedSchedule):
                            AppLogger.shared.debug("Updated schedule with id: \(fetchedSchedule.id)")
                            self.updateSchedule(schedule: fetchedSchedule)
                        case .failure(let failure):
                            AppLogger.shared.debug("Updating could not finish due to network error: \(failure)")
                        }
                })
            }
        } else {
            AppLogger.shared.debug("No bookmarks or school id available")
        }
    }
    
    func updateSchedule(schedule: Response.Schedule) {
        let realmSchedule: Schedule = schedule.toRealmSchedule(existingCourseColors: getCourseColors())
        if let realm = try? Realm() {
            if let scheduleToUpdate = realm.objects(Schedule.self).first(where: { $0.scheduleId == schedule.id }) {
                try! realm.write {
                    scheduleToUpdate.days = realmSchedule.days
                    scheduleToUpdate.cachedAt = realmSchedule.cachedAt
                }
            }
        }
    }
    
    func getCourseColors() -> [String : String] {
        let realm = try! Realm()
        let courses = realm.objects(Course.self)
        var courseColors: [String: String] = [:]
        for course in courses {
            courseColors[course.courseId] = course.color
        }
        return courseColors
    }

}
