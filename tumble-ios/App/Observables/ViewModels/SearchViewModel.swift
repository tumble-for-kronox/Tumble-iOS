//
//  SearchView-ViewModel.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 11/17/22.
//

import Foundation
import SwiftUI

enum SearchStatus {
    case initial
    case loading
    case loaded
    case error
    case empty
}

enum SchedulePreviewStatus {
    case loaded
    case loading
    case error
    case empty
}

@MainActor final class SearchViewModel: ObservableObject {
    
    @Inject var courseColorService: CourseColorService
    @Inject var scheduleService: ScheduleService
    @Inject var preferenceService: PreferenceService
    @Inject var networkManager: NetworkManager
    @Inject var notificationManager: NotificationManager
    
    @Published var status: SearchStatus = .initial
    @Published var programmeSearchResults: [Response.Programme] = []
    @Published var scheduleForPreview: Response.Schedule? = nil
    @Published var scheduleListOfDays: [DayUiModel]? = nil
    @Published var presentPreview: Bool = false
    @Published var schedulePreviewStatus: SchedulePreviewStatus = .loading
    @Published var schedulePreviewIsSaved: Bool = false
    @Published var courseColors: [String : String]? = nil
    @Published var school: School?
    @Published var errorMessage: String? = nil
    @Published var previewButtonState: ButtonState = .loading
    
    
    
    init() {
        self.school = preferenceService.getDefaultSchool()
    }
    
    
    func update() -> Void {
        self.presentPreview = false
        self.status = .initial
        self.scheduleForPreview = nil
        self.programmeSearchResults.removeAll()
        self.courseColors = nil
        self.school = preferenceService.getDefaultSchool()
    }
    
    
    // When user presses a programme card
    func onOpenProgrammeSchedule(programmeId: String) -> Void {

        // Set sheet view as loading and reset possible old
        // value for the save button
        self.schedulePreviewIsSaved = false
        self.schedulePreviewStatus = .loading
        self.presentPreview = true
        self.scheduleForPreview = nil
        
        // Check if schedule is already saved, to set flag
        self.checkSavedSchedule(programmeId: programmeId) {
            
            // Always get latest schedule
            self.fetchSchedule(programmeId: programmeId) { fetchedSchedule in
                if fetchedSchedule {
                    // If the schedule is saved just make sure all colors are available
                    // and loaded into view
                    if self.schedulePreviewIsSaved {
                        self.loadProgrammeCourseColors { courseColors in
                            DispatchQueue.main.async {
                                self.courseColors = courseColors
                                self.previewButtonState = .saved
                                self.schedulePreviewStatus = .loaded
                            }
                        }
                    }
                    // Otherwise load random course colors
                    else {
                        self.assignRandomCourseColors { [weak self] (result: Result<[String : String], Error>) in
                            guard let self = self else { return }
                            switch result {
                            case .success(let courseColors):
                                DispatchQueue.main.async {
                                    // Assign possibly updated course colors
                                    self.courseColors = courseColors
                                    self.previewButtonState = .notSaved
                                    self.schedulePreviewStatus = .loaded
                                }
                            case .failure(let failure):
                                AppLogger.shared.debug("\(failure)")
                                DispatchQueue.main.async {
                                    self.schedulePreviewStatus = .error
                                }
                            }
                            
                        }
                    }
                } else {
                    DispatchQueue.main.async {
                        self.schedulePreviewStatus = .error
                    }
                    return
                }
            }
        }
    }
    
    
    func onSearchProgrammes(searchQuery: String) -> Void {
        self.status = .loading
        networkManager.get(.searchProgramme(
            searchQuery: searchQuery,
            schoolId: String(school!.id)),
            sessionToken: nil) { [weak self] (result: Result<Response.Search, Response.ErrorMessage>) in
                guard let self = self else { return }
                switch result {
                case .success(let result):
                    self.parseSearchResults(result)
                case .failure(let error):
                    DispatchQueue.main.async {
                        self.status = SearchStatus.error
                    }
                    AppLogger.shared.debug("Encountered error when trying to search for programme \(searchQuery): \(error)")
                }
        }
    }
    
    
    func onClearSearch(endEditing: Bool) -> Void {
        if (endEditing) {
            self.programmeSearchResults = []
            self.status = .initial
        }
    }
    
    
    func onBookmark(
        updateButtonState: @escaping () -> Void,
        checkForNewSchedules: @escaping () -> Void) -> Void {
            DispatchQueue.main.async {
                self.previewButtonState = .loading
            }
            // If the schedule isn't already saved in the local database
            if !self.schedulePreviewIsSaved {
                self.saveSchedule(completion: { [weak self] result in
                    guard let self = self else { return }
                    switch result {
                    case .success:
                        DispatchQueue.main.async {
                            self.preferenceService.setBookmarks(bookmark: self.scheduleForPreview!.id)
                            self.previewButtonState = .saved
                            updateButtonState()
                            checkForNewSchedules()
                        }
                        return
                    case .failure:
                        DispatchQueue.main.async {
                            self.schedulePreviewStatus = .error
                        }
                    }
                })
            }
            // Otherwise we remove (untoggle) the schedule
            else {
                self.loadSchedules { [weak self] schedules in
                    guard let self = self else { return }
                    let schedulesToRemove = schedules.filter { $0.id == self.scheduleForPreview?.id }
                    let events = schedulesToRemove
                        .flatMap { schedule in schedule.days }
                        .flatMap { day in day.events }
                    events.forEach { event in self.notificationManager.cancelNotification(for: event.id) }
                    self.removeSchedule(completion: { [weak self] result in
                        guard let self = self else { return }
                        switch result {
                        case .success:
                            DispatchQueue.main.async {
                                self.previewButtonState = .notSaved
                                updateButtonState()
                            }
                            checkForNewSchedules()
                            return
                        case .failure:
                            DispatchQueue.main.async {
                                self.schedulePreviewStatus = .error
                            }
                        }
                    })
                }
            }
    }

    
    func resetSearchResults() -> Void {
        self.programmeSearchResults = []
        self.status = .initial
    }
    
}



extension SearchViewModel {
    
    // Checks if a schedule based on its programme Id is already in the
    // local storage. if it is, we set the preview button for favoriting
    // to be either save or remove.
    fileprivate func checkSavedSchedule(programmeId: String, closure: @escaping () -> Void) -> Void {
        AppLogger.shared.debug("Checking if schedule is already saved...")
        scheduleService.load(with: programmeId) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .failure(_):
                AppLogger.shared.debug("Schedule was not previously saved")
                self.schedulePreviewIsSaved = false
                break
            case .success(_):
                self.schedulePreviewIsSaved = true
                AppLogger.shared.debug("Schedule is already saved")
            }
            closure()
        }
    }
    
    
    fileprivate func handleFetchedSchedule(schedule: Response.Schedule, closure: @escaping () -> Void) -> Void {
        if schedule.isEmpty() {
            DispatchQueue.main.async {
                self.schedulePreviewStatus = .empty
            }
        } else {
            self.scheduleForPreview = schedule
            self.scheduleListOfDays = schedule.days.toOrderedDays()
            AppLogger.shared.debug("Set schedule local variables")
        }
        closure()
    }
    
    
    // Assigns course colors to a schedule if it was found in the local storage.
    // This function should ONLY be called when a schedule is found in the local storage.
    // The purpose is to check for new schedules and add them accordingly
    fileprivate func assignCourseColorsToSavedSchedule(
        courses: [String : String],
        closure: @escaping ([String : String]) -> Void) -> Void {
            var availableColors = Set(colors)
            var courseColors = courses
            let visitedCourses = self.scheduleListOfDays!.flatMap {
                $0.events.map {
                    $0.course.id } }.filter {
                        !courseColors.keys.contains($0)
                    }
            for course in visitedCourses {
                courseColors[course] = availableColors.popFirst()
            }
            self.saveCourseColors(courseColors: courseColors)
            closure(courseColors)
    }
    
    
    // API Call to fetch a schedule from backend
    fileprivate func fetchSchedule(programmeId: String, closure: @escaping (Bool) -> Void) -> Void {
        networkManager.get(
            .schedule(
                scheduleId: programmeId,
                schoolId: String(school!.id))) { [weak self] (result: Result<Response.Schedule, Response.ErrorMessage>) in
                    DispatchQueue.main.async {
                        guard let self = self else { return }
                        switch result {
                        case .success(let result):
                            AppLogger.shared.debug("Fetched schedule")
                            self.handleFetchedSchedule(schedule: result) {
                                closure(true)
                            }
                        case .failure(let error):
                            closure(false)
                            self.schedulePreviewStatus = .error
                            self.errorMessage = error.message
                            AppLogger.shared.debug("Encountered error when attempting to load schedule for programme \(programmeId): \(error)")
                        }
                    }
        }
    }
    
    
    fileprivate func assignRandomCourseColors(closure: @escaping (Result<[String : String], Error>) -> Void) -> Void {
        if let randomCourseColors = self.scheduleForPreview?.assignCoursesRandomColors() {
            closure(.success(randomCourseColors))
        } else {
            closure(.failure(.generic(reason: "Schedule for preview is null")))
        }
    }
    
    
    fileprivate func saveSchedule(completion: @escaping (Result<Void, Error>) -> Void) {
        guard let schedule = self.scheduleForPreview,
              let courseColors = self.courseColors
        else {
            completion(.failure(.generic(reason: "scheduleForPreview or courseColors is nil")))
            return
        }

        scheduleService.save(schedule: schedule) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success:
                self.saveCourseColors(courseColors: courseColors)
                self.schedulePreviewIsSaved = true
                completion(.success(()))
            case .failure(let error):
                AppLogger.shared.debug("Fatal error \(error)")
                completion(.failure(error))
            }
        }
    }


    
    
    fileprivate func removeSchedule(completion: @escaping (Result<Void, Error>) -> Void) -> Void {
        
        guard self.scheduleForPreview != nil else {
            completion(.failure(.generic(reason: "scheduleForPreview")))
            return
        }
        
        scheduleService.remove(scheduleId: self.scheduleForPreview!.id) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success:
                DispatchQueue.main.async {
                    self.schedulePreviewIsSaved = false
                }
                self.removeCourseColors(completion: completion)
                return
            case .failure(let error):
                AppLogger.shared.debug("Fatal error \(error)")
                completion(.failure(error))
            }
        }
    }

    fileprivate func removeCourseColors(completion: @escaping (Result<Void, Error>) -> Void) -> Void {
        courseColorService.remove(removeCourses: (self.scheduleForPreview!.courses())) { result in
            if case .failure(let error) = result {
                AppLogger.shared.debug("Fatal error \(error)")
                completion(.failure(.generic(reason: error.localizedDescription)))
                return
            } else {
                AppLogger.shared.debug("Removed course colors")
                completion(.success(()))
            }
        }
    }

    
    
    fileprivate func loadProgrammeCourseColors(closure: @escaping ([String : String]) -> Void) -> Void {
        courseColorService.load { result in
            DispatchQueue.main.async {
                switch result {
                case .failure(_):
                    AppLogger.shared.debug("Could not load course colors for saved schedule")
                case .success(let courses):
                    if !courses.isEmpty {
                        self.assignCourseColorsToSavedSchedule(courses: courses) { newCourseColors in
                            closure(newCourseColors)
                        }
                    }
                }
            }
        }
    }
    
    
    fileprivate func saveCourseColors(courseColors: [String : String]) -> Void {
        self.courseColorService.save(coursesAndColors: courseColors) { courseResult in
            if case .failure(let error) = courseResult {
                fatalError(error.localizedDescription)
            } else {
                AppLogger.shared.debug("Successfully saved course colors")
            }
        }
    }
    
    
    fileprivate func parseSearchResults(_ results: Response.Search) -> Void {
        var localResults = [Response.Programme]()
        for result in results.items {
            localResults.append(result)
        }
        DispatchQueue.main.async {
            self.programmeSearchResults = localResults
            self.status = .loaded
        }
    }
    
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
    
}
