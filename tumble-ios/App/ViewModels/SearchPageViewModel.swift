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

extension SearchPage {
    @MainActor final class SearchPageViewModel: ObservableObject {
        
        @Inject var courseColorService: CourseColorService
        @Inject var scheduleService: ScheduleService
        @Inject var preferenceService: PreferenceService
        @Inject var networkManager: NetworkManager
        
        @Published var status: SearchStatus = .initial
        @Published var programmeSearchResults: [Response.Programme] = []
        @Published var scheduleForPreview: Response.Schedule? = nil
        @Published var scheduleListOfDays: [DayUiModel]? = nil
        @Published var presentPreview: Bool = false
        @Published var schedulePreviewStatus: SchedulePreviewStatus = .loading
        @Published var schedulePreviewIsSaved: Bool = false
        @Published var courseColors: [String : String]? = nil
        @Published var school: School?
        
        
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
            
            // Check if schedule is already saved, to set flag
            self.checkSavedSchedule(programmeId: programmeId) {
                
                // Always get latest schedule
                self.fetchSchedule(programmeId: programmeId) {
                    // If the schedule is saved just make sure all colors are available
                    // and loaded into view
                    if self.schedulePreviewIsSaved {
                        self.loadProgrammeCourseColors() { courseColors in
                            self.courseColors = courseColors
                            self.schedulePreviewStatus = .loaded
                        }
                    }
                    // Otherwise load random course colors
                    else {
                        self.assignRandomCourseColors() { courseColors in
                            // Assign possibly updated course colors
                            self.courseColors = courseColors
                            self.schedulePreviewStatus = .loaded
                        }
                    }
                }
            }
        }
        
        
        func onSearchProgrammes(searchQuery: String) -> Void {
            self.status = .loading
            networkManager.get(.searchProgramme(searchQuery: searchQuery, schoolId: String(school!.id)), authToken: nil) { [weak self] (result: Result<Response.Search, Error>) in
                DispatchQueue.main.async {
                    guard let self = self else { return }
                    switch result {
                    case .success(let result):
                        self.parseSearchResults(result)
                    case .failure(let error):
                        self.status = SearchStatus.error
                        AppLogger.shared.info("Encountered error when trying to search for programme \(searchQuery): \(error)")
                    }
                }
            }
        }
        
        
        func onClearSearch(endEditing: Bool) -> Void {
            if (endEditing) {
                self.programmeSearchResults = []
                self.status = .initial
            }
        }
        
        
        func onBookmark(checkForNewSchedules: @escaping () -> Void) -> ButtonState {
            // If the schedule isn't already saved in the local database
            if !self.schedulePreviewIsSaved {
                self.saveSchedule(checkForNewSchedules: checkForNewSchedules)
                self.preferenceService.setBookmarks(bookmark: scheduleForPreview!.id)
                return .saved
            }
            // Otherwise we remove (untoggle) the schedule
            else {
                self.removeSchedule(checkForNewSchedules: checkForNewSchedules)
                return .notSaved
            }
        }

        
        func resetSearchResults() -> Void {
            self.programmeSearchResults = []
            self.status = .initial
        }
    }
}



extension SearchPage.SearchPageViewModel {
    
    // Checks if a schedule based on its programme Id is already in the
    // local storage -> schedulePreviewIsSaved = true
    fileprivate func checkSavedSchedule(programmeId: String, closure: @escaping () -> Void) -> Void {
        scheduleService.load { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                switch result {
                case .failure(_):
                    AppLogger.shared.info("Schedule was not previously saved")
                    break
                case .success(let schedule):
                    if !schedule.isEmpty {
                        if (schedule.contains(where: { $0.id == programmeId })) {
                            self.schedulePreviewIsSaved = true
                            AppLogger.shared.info("Schedule is already saved")
                        }
                    }
                }
                closure()
            }
        }
    }
    
    
    fileprivate func handleFetchedSchedule(schedule: Response.Schedule, closure: @escaping () -> Void) -> Void {
        if schedule.isEmpty() {
            self.schedulePreviewStatus = .empty
        } else {
            self.scheduleForPreview = schedule
            self.scheduleListOfDays = schedule.days.toOrderedDays()
            AppLogger.shared.info("Set schedule local variables")
        }
        closure()
    }
    
    
    // Assigns course colors to a schedule if it was found in the local storage.
    // This function should ONLY be called when a schedule is found in the local storage.
    // The purpose is to check for new schedules and add them accordingly
    fileprivate func assignCourseColorsToSavedSchedule(courses: [String : String], closure: @escaping ([String : String]) -> Void) -> Void {
        var availableColors = Set(colors)
        var courseColors = courses
        let visitedCourses = self.scheduleListOfDays!.flatMap { $0.events.map { $0.course.id } }.filter { !courseColors.keys.contains($0) }
        for course in visitedCourses {
            courseColors[course] = availableColors.popFirst()
        }
        self.saveCourseColors(courseColors: courseColors)
        closure(courseColors)
    }

    
    // API Call to fetch a schedule from backend
    fileprivate func fetchSchedule(programmeId: String, closure: @escaping () -> Void) -> Void {
        networkManager.get(.schedule(scheduleId: programmeId, schoolId: String(school!.id)), authToken: nil) { [weak self] (result: Result<Response.Schedule, Error>) in
            DispatchQueue.main.async {
                guard let self = self else { return }
                switch result {
                case .success(let result):
                    AppLogger.shared.info("Fetched schedule")
                    self.handleFetchedSchedule(schedule: result) {
                        closure()
                    }
                case .failure(let error):
                    self.schedulePreviewStatus = .error
                    AppLogger.shared.info("Encountered error when attempting to load schedule for programme \(programmeId): \(error)")
                }
            }
        }
    }
    
    
    fileprivate func assignRandomCourseColors(closure: @escaping ([String : String]) -> Void) -> Void {
        let randomCourseColors = self.scheduleForPreview!.assignCoursesRandomColors()
        closure(randomCourseColors)
    }
    
    
    fileprivate func saveSchedule(checkForNewSchedules: @escaping () -> Void) -> Void {
        scheduleService.save(schedule: self.scheduleForPreview!) { [weak self] scheduleResult in
            DispatchQueue.main.async {
                guard let self = self else { return }
                if case .failure(let error) = scheduleResult {
                    fatalError(error.localizedDescription)
                } else {
                    self.saveCourseColors(courseColors: (self.courseColors!))
                    self.schedulePreviewIsSaved = true
                    checkForNewSchedules()
                }
            }
        }
    }
    
    
    fileprivate func removeSchedule(checkForNewSchedules: @escaping () -> Void) -> Void {
        scheduleService.remove(scheduleId: self.scheduleForPreview!.id) { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                if case .failure(let error) = result {
                    fatalError(error.localizedDescription)
                } else {
                    self.schedulePreviewIsSaved = false
                    self.courseColorService.remove(removeCourses: (self.scheduleForPreview!.courses())) { result in
                        if case .failure(let error) = result {
                            fatalError(error.localizedDescription)
                        } else {
                            AppLogger.shared.info("Removed course colors")
                            checkForNewSchedules()
                        }
                    }
                }
            }
        }
    }
    
    
    fileprivate func loadProgrammeCourseColors(closure: @escaping ([String : String]) -> Void) -> Void {
        courseColorService.load { result in
            DispatchQueue.main.async {
                switch result {
                case .failure(_):
                    AppLogger.shared.info("Could not load course colors for saved schedule")
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
                AppLogger.shared.info("Successfully saved course colors")
            }
        }
    }
    
    
    fileprivate func parseSearchResults(_ results: Response.Search) -> Void {
        var localResults = [Response.Programme]()
        for result in results.items {
            localResults.append(result)
        }
        self.programmeSearchResults = localResults
        self.status = .loaded
    }
    
}
