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

extension SearchParentView {
    @MainActor final class SearchViewModel: ObservableObject {
        @Published var searchBarText: String = ""
        @Published var searchResultText: String = ""
        @Published var status: SearchStatus = .initial
        @Published var numberOfSearchResults: Int = 0
        @Published var searchResults: [Response.Programme] = []
        @Published var scheduleForPreview: Response.Schedule? = nil
        @Published var scheduleListOfDays: [DayUiModel]? = nil
        @Published var presentPreview: Bool = false
        @Published var schedulePreviewStatus: SchedulePreviewStatus = .loading
        @Published var schedulePreviewIsSaved: Bool = false
        @Published var availableCourseColors: CourseAndColorDict = [:]
        
        
        // Course name and hex color
        @Published var courseColors: [String : String]? = nil
        
        @Published var school: School?
        let scheduleService: ScheduleServiceImpl
        let courseColorService: CourseColorServiceImpl
        
        init(school: School?, scheduleService: ScheduleServiceImpl, courseColorService: CourseColorServiceImpl) {
            self.school = school
            self.scheduleService = scheduleService
            self.courseColorService = courseColorService
        }
        
        private var client: APIClient = APIClient.shared
        
        // Checks if a schedule based on its programme Id is already in the
        // local storage -> schedulePreviewIsSaved = true
        private func checkSavedSchedule(programmeId: String, closure: @escaping () -> Void) -> Void {
            scheduleService.load { result in
                DispatchQueue.main.async {
                    switch result {
                    case .failure(_):
                        break
                    case .success(let schedule):
                        if !schedule.isEmpty {
                            if (schedule.contains(where: { $0.id == programmeId })) {
                                self.schedulePreviewIsSaved = true
                            }
                        }
                    }
                    closure()
                }
            }
        }
        
        fileprivate func handleFetchedSchedule(schedule: Response.Schedule) -> Void {
            if schedule.isEmpty() {
                self.schedulePreviewStatus = .empty
            } else {
                self.scheduleForPreview = schedule
                self.scheduleListOfDays = schedule.days.toOrderedDays()
            }
        }
        
        // Assigns course colors to a schedule if it was found in the local storage.
        // This function should ONLY be called when a schedule is found in the local storage.
        // The purpose is to check for new schedules and add them accordingly
        fileprivate func assignCourseColorsToSavedSchedule(courses: [String : String]) -> Void {
            var availableColors = Set(colors)
            var courseColors = courses
            var visitedCourses: [String] = []
            // Check for new courses and update local storage since it is saved
            for day in self.scheduleListOfDays! {
                for event in day.events {
                    if !(visitedCourses.contains(event.course.id)) {
                        visitedCourses.append(event.course.id)
                    }
                    // If a new course is found in force loaded schedule
                    if (courseColors[event.course.id] == nil) {
                        courseColors[event.course.id] = availableColors.popFirst()
                    }
                }
            }
            self.saveCourseColors(courseColors: courses)
            // Assign possibly updated course colors
            self.courseColors = courses
        }
        
        // API Call to fetch a schedule from backend
        fileprivate func fetchSchedule(programmeId: String, closure: @escaping () -> Void) -> Void {
            client.get(.schedule(scheduleId: programmeId, schoolId: String(school!.id))) { (result: Result<Response.Schedule, Error>) in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let result):
                        self.handleFetchedSchedule(schedule: result)
                    case .failure(_):
                        self.schedulePreviewStatus = .error
                    }
                    closure()
                }
            }
        }
        
        // When user presses a programme card
        func onOpenProgramme(programmeId: String) -> Void {
            
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
                        self.loadProgrammeCourseColors()
                    }
                    // Otherwise load random course colors
                    else {
                        self.assignRandomCourseColors()
                    }
                    
                    self.schedulePreviewStatus = .loaded
                }
            }
        }
        
        func onSearchProgrammes(searchQuery: String) -> Void {
            self.status = .loading
            self.searchResultText = self.searchBarText
            client.get(.searchProgramme(searchQuery: searchQuery, schoolId: String(school!.id))) { (result: Result<Response.Search, Error>) in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let result):
                        self.status = SearchStatus.loading
                        self.parseSearchResults(result)
                    case .failure( _):
                        self.status = SearchStatus.error
                        print("error")
                    }
                }
            }
        }
        
        func onClearSearch(endEditing: Bool) -> Void {
            if (endEditing) {
                self.searchResults = []
                self.status = .initial
            }
            self.searchBarText = ""
        }
        
        func onBookmark(checkForNewSchedules: @escaping () -> Void) -> Void {
            // If the schedule isn't already saved in the local database
            if !self.schedulePreviewIsSaved {
                self.saveSchedule(checkForNewSchedules: checkForNewSchedules)
            }
            // Otherwise we remove (untoggle) the schedule
            else {
                self.removeSchedule(checkForNewSchedules: checkForNewSchedules)
            }
        }
        
        fileprivate func assignRandomCourseColors() -> Void {
            self.courseColors = self.scheduleForPreview!.assignCoursesRandomColors()
        }
        
        fileprivate func saveSchedule(checkForNewSchedules: @escaping () -> Void) -> Void {
            scheduleService.save(schedule: self.scheduleForPreview!) { scheduleResult in
                DispatchQueue.main.async {
                    if case .failure(let error) = scheduleResult {
                        fatalError(error.localizedDescription)
                    } else {
                        self.saveCourseColors(courseColors: self.courseColors!)
                        checkForNewSchedules()
                    }
                }
            }
        }
        
        fileprivate func removeSchedule(checkForNewSchedules: @escaping () -> Void) -> Void {
            scheduleService.remove(schedule: self.scheduleForPreview!) { result in
                DispatchQueue.main.async {
                    if case .failure(let error) = result {
                        fatalError(error.localizedDescription)
                    } else {
                        self.schedulePreviewIsSaved = false
                        self.courseColorService.remove(removeCourses: self.scheduleForPreview!.courses()) { result in
                            if case .failure(let error) = result {
                                fatalError(error.localizedDescription)
                            } else {
                                checkForNewSchedules()
                            }
                        }
                    }
                }
            }
        }
        
        fileprivate func loadProgrammeCourseColors() -> Void {
            courseColorService.load { result in
                DispatchQueue.main.async {
                    switch result {
                    case .failure(_):
                        print("Could not load course colors")
                    case .success(let courses):
                        if !courses.isEmpty {
                            self.assignCourseColorsToSavedSchedule(courses: courses)
                        }
                    }
                }
            }
        }
        
        fileprivate func saveCourseColors(courseColors: [String : String]) -> Void {
            self.courseColorService.save(coursesAndColors: courseColors) { courseResult in
                if case .failure(let error) = courseResult {
                    fatalError(error.localizedDescription)
                }
            }
        }
        
        fileprivate func parseSearchResults(_ results: Response.Search) -> Void {
            var localResults = [Response.Programme]()
            self.numberOfSearchResults = results.count
            for result in results.items {
                localResults.append(result)
            }
            self.searchResults = localResults
            self.status = .loaded
        }
    }
}
