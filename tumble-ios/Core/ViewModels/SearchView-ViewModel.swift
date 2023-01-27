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
    @MainActor class SearchViewModel: ObservableObject {
        @Published var searchBarText: String = ""
        @Published var searchResultText: String = ""
        @Published var isEditing: Bool = false
        @Published var status: SearchStatus = .initial
        @Published var numberOfSearchResults: Int = 0
        @Published var searchResults: [API.Types.Response.Programme] = []
        @Published var scheduleForPreview: API.Types.Response.Schedule? = nil
        @Published var scheduleListOfDays: [DayUiModel]? = nil
        @Published var presentPreview: Bool = false
        @Published var schedulePreviewStatus: SchedulePreviewStatus = .loading
        @Published var school: School? = UserDefaults.standard.getDefaultSchool()
        @Published var schedulePreviewIsSaved: Bool = false
        @Published var courseColors: CourseAndColorDict = [:]
        
        private var client: API.Client = API.Client.shared
        
        private func checkSavedSchedule(scheduleId: String) -> Void {
            ScheduleStore.load { result in
                DispatchQueue.main.async {
                    switch result {
                    case .failure(_):
                        break
                    case .success(let schedules):
                        if !schedules.isEmpty {
                            if (schedules.contains(where: { $0.id == scheduleId })) {
                                print("Schedule is saved")
                                self.schedulePreviewIsSaved = true
                            }
                        }
                    }
                }
            }
        }
        
        // Handles child modal status, [.loaded, .loading, .error, .empty]
        func onLoadSchedule(programme: API.Types.Response.Programme) -> Void {
            self.schedulePreviewIsSaved = false
            self.schedulePreviewStatus = .loading
            self.presentPreview = true
            self.checkSavedSchedule(scheduleId: programme.id)
            client.get(.schedule(scheduleId: programme.id, schoolId: String(school!.id))) { (result: Result<API.Types.Response.Schedule, API.Types.Error>) in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let result):
                        self.scheduleForPreview = result
                        self.scheduleListOfDays = result.days.toOrderedDays()
                        self.initCourseColors()
                        self.presentPreview = true
                        self.schedulePreviewStatus = .loaded
                    case .failure(_):
                        self.schedulePreviewStatus = .error
                    }
                }
            }
        }
        
        func getCourseColors() -> [String : [String : Color]] {
            return courseColors.reduce(into: [:]) { (coursesAndColorsDict, course) in
                let (courseId, color) = course
                coursesAndColorsDict[courseId, default: [:]][color] = hexStringToUIColor(hex: color)
            }
        }

        
        func onBookmark(courseColors: [String : [String : Color]]) -> Void {
            // If the schedule isn't already saved in the local database
            if !self.schedulePreviewIsSaved {
                ScheduleStore.save(schedule: self.scheduleForPreview!) { scheduleResult in
                    DispatchQueue.main.async {
                        if case .failure(let error) = scheduleResult {
                            fatalError(error.localizedDescription)
                        } else {
                            print("Saving schedule")
                            self.schedulePreviewIsSaved = true
                            CourseColorStore.save(coursesAndColors: courseColors) { courseResult in
                                if case .failure(let error) = courseResult {
                                    fatalError(error.localizedDescription)
                                } else {
                                    print("Applying course colors ...")
                                }
                            }
                        }
                    }
                }
            }
            // Otherwise we remove (untoggle) the schedule
            else {
                print("Removing schedule")
                ScheduleStore.remove(schedule: self.scheduleForPreview!) { result in
                    DispatchQueue.main.async {
                        if case .failure(let error) = result {
                            fatalError(error.localizedDescription)
                        } else {
                            print("Removed schedule")
                            self.schedulePreviewIsSaved = false
                            CourseColorStore.remove(removeCourses: self.scheduleForPreview!.courses()) { result in
                                if case .failure(let error) = result {
                                    fatalError(error.localizedDescription)
                                } else {
                                    print("Removed course colors ...")
                                }
                            }
                        }
                    }
                }
            }
        }
        
        func onSearchProgrammes(searchQuery: String) -> Void {
            self.status = .loading
            self.searchResultText = self.searchBarText
            client.get(.searchProgramme(searchQuery: searchQuery, schoolId: String(school!.id))) { (result: Result<API.Types.Response.Search, API.Types.Error>) in
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
                self.isEditing = false
                self.searchResults = []
                self.status = .initial
            }
            self.searchBarText = ""
        }
        
        func initCourseColors() -> Void {
            for day in self.scheduleListOfDays! {
                for event in day.events {
                    CourseColorStore.load { result in
                        DispatchQueue.main.async {
                            switch result {
                            case .failure(_):
                                print("Error on course with id: \(event.course.id)")
                            case .success(let courses):
                                if !courses.isEmpty {
                                    self.courseColors = courses
                                }
                            }
                        }
                    }
                }
            }
        }
        
        
        // Private functions
        private func parseSearchResults(_ results: API.Types.Response.Search) -> Void {
            var localResults = [API.Types.Response.Programme]()
            self.numberOfSearchResults = results.count
            for result in results.items {
                localResults.append(result)
            }
            self.searchResults = localResults
            self.status = .loaded
        }
    }
}
