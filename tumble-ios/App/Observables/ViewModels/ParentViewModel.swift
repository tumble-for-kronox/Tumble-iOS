//
//  ParentViewModel.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 11/16/22.
//

import Foundation
import SwiftUI
import Combine

// Parent/Container for other viewmodels
final class ParentViewModel: ObservableObject {
    
    var viewModelFactory: ViewModelFactory = ViewModelFactory.shared
    
    @Inject var scheduleService: ScheduleService
    @Inject var courseColorService: CourseColorService
    @Inject var preferenceService: PreferenceService
    @Inject var kronoxManager: KronoxManager
    
    lazy var homeViewModel: HomeViewModel = viewModelFactory.makeViewModelHome()
    lazy var bookmarksViewModel: BookmarksViewModel = viewModelFactory.makeViewModelBookmarks()
    lazy var accountPageViewModel: AccountViewModel = viewModelFactory.makeViewModelAccount()
    lazy var searchViewModel: SearchViewModel = viewModelFactory.makeViewModelSearch()
    lazy var settingsViewModel: SettingsViewModel = viewModelFactory.makeViewModelSettings()
    
    @Published var schedules: [ScheduleData] = []
    @Published var courseColors: CourseAndColorDict = [:]
    
    private var cancellables = Set<AnyCancellable>()
    
    init () {
        setUpDataPublishers()
        //updateBookmarks()
    }
    
    func setUpDataPublishers() -> Void {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self else { return }
            let schedulesPublisher = scheduleService.$schedules.receive(on: DispatchQueue.main)
            let courseColorsPublisher = courseColorService.$courseColors.receive(on: DispatchQueue.main)
            Publishers.CombineLatest(schedulesPublisher, courseColorsPublisher)
                .sink { schedules, courseColors in
                    if self.schedules != schedules {
                        self.schedules = schedules
                        self.courseColors = courseColors
                        self.updateBookmarks()
                    }
                }
                .store(in: &cancellables)
        }
    }
    
    func updateBookmarks() -> Void {
        // Get all stored shedule id's from preferences
        let bookmarks: [Bookmark]? = preferenceService.getBookmarks()
        let schoolId: Int? = preferenceService.getDefaultSchool()
        if let bookmarks = bookmarks, let schoolId = schoolId {
            for bookmark in bookmarks {
                let scheduleId: String = bookmark.id
                let currentImageOfSchedule: ScheduleData? = schedules.first(where: { $0.id == scheduleId })
                guard let currentSchedule = currentImageOfSchedule else { return }
                let endpoint: Endpoint = .schedule(scheduleId: scheduleId, schoolId: String(schoolId))
                // Fetch schedule from backend
                let _ = kronoxManager.get(endpoint, then: {
                    [weak self] (result: Result<Response.Schedule, Response.ErrorMessage>) in
                        guard let self else { return }
                        switch result {
                        case .success(let fetchedSchedule):
                            AppLogger.shared.info("Updated schedule with id: \(fetchedSchedule.id)")
                            self.assignMissingCourseColors(
                                fetchedSchedule: fetchedSchedule,
                                currentSchedule: currentSchedule)
                        case .failure(let failure):
                            AppLogger.shared.info("Updating could not finish due to network error: \(failure)")
                        }
                })
            }
        } else {
            AppLogger.shared.info("No bookmarks or school id available")
        }
    }
    
    // Assigns missing course colors to the
    // new schedule if any new courses are found
    func assignMissingCourseColors(
        fetchedSchedule: Response.Schedule,
        currentSchedule: ScheduleData) -> Void {
        let coursesForFetchedSchedule: [String] = fetchedSchedule.courses()
        let coursesForCurrentSchedule: [String] = currentSchedule.courses()
        let missingCourses = coursesForFetchedSchedule.filter { !coursesForCurrentSchedule.contains($0) }
        var colors = Set(colors)
        var courseColors = courseColors
        for course in missingCourses {
            courseColors[course] = colors.popFirst()
        }
        saveCourseColors(courseColors: courseColors, completion: { [weak self] result in
            guard let self else { return }
            switch result {
            case .success:
                AppLogger.shared.info("Successfully updated schedule and course colors")
            case .failure:
                AppLogger.shared.error("Failed to update schedule and course colors")
                removeScheduleAndColors(
                    courseColorsToRemove: coursesForCurrentSchedule,
                    scheduleIdToRemove: currentSchedule.id)
            }
        })
    }
    
    // Save course colors of specific schedule
    // to local storage
    func saveCourseColors(
        courseColors: [String : String],
        completion: @escaping (Result<Void, Error>) -> Void) -> Void {
        self.courseColorService.save(coursesAndColors: courseColors) { courseResult in
            if case .failure(let failure) = courseResult {
                completion(.failure(.internal(reason: "Fatal error occurred: \(failure)")))
            } else {
                AppLogger.shared.debug("Successfully saved course colors")
                completion(.success(()))
            }
        }
    }
    
    // If after updating, storing schedule and course colors fails,
    // we remove the schedule altogether to avoid strange behavior
    func removeScheduleAndColors(
        courseColorsToRemove: [String],
        scheduleIdToRemove: String
    ) -> Void {
        scheduleService.remove(scheduleId: scheduleIdToRemove, completion: { [weak self] result in
            guard let self else { return }
            switch result {
            case .success:
                self.courseColorService.remove(removeCourses: courseColorsToRemove, completion: { result in
                    switch result {
                    case .success:
                        AppLogger.shared.info("Removed schedule and courses due to internal error")
                    case .failure:
                        AppLogger.shared.error("Could not remove course colors")
                    }
                })
            case .failure:
                AppLogger.shared.error("Could not remove schedule")
            }
        })
    }
}
