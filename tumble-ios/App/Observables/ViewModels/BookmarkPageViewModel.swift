//
//  SchedulePageMainView-ViewModel.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 11/21/22.
//

import Foundation
import SwiftUI


enum BookmarksViewStatus {
    case loading
    case loaded
    case uninitialized
    case hiddenAll
    case error
}

extension BookmarkPage {
    @MainActor final class BookmarkPageViewModel: ObservableObject {
        
        let viewModelFactory: ViewModelFactory = ViewModelFactory()
        
        @Inject var scheduleService: ScheduleService
        @Inject var preferenceService: PreferenceService
        @Inject var courseColorService: CourseColorService
        @Inject var networkManager: NetworkManager
        
        @Published var scheduleViewTypes: [BookmarksViewType] = BookmarksViewType.allValues
        @Published var status: BookmarksViewStatus = .loading
        @Published var scheduleListOfDays: [DayUiModel] = []
        @Published var courseColors: [String : String] = [:]
        @Published var defaultViewType: BookmarksViewType
        @Published var school: School?
        
        
        init () {
            self.defaultViewType = .list
            self.loadBookmarkedSchedules()
            self.defaultViewType = preferenceService.getDefaultViewType()
            self.school = preferenceService.getDefaultSchool()
        }
        
        
        func generateViewModelEventSheet(event: Response.Event, color: Color) -> EventDetailsSheet.EventDetailsSheetViewModel {
            return viewModelFactory.makeViewModelEventDetailsSheet(event: event, color: color)
        }
        
        
        func updateViewLocals() -> Void {
            self.school = preferenceService.getDefaultSchool()
        }
        
        func updateCourseColors() -> Void {
            self.loadCourseColors() { courseColors in
                self.courseColors = courseColors
            }
        }
        
        func loadBookmarkedSchedules() -> Void {
            // Load schedules from local storage
            self.loadSchedules { [weak self] schedules in
                guard let self = self else { return }
                let hiddenBookmarks = self.getHiddenBookmarks()
                let visibleSchedules = self.filterBookmarks(schedules: schedules, hiddenBookmarks: hiddenBookmarks)
                AppLogger.shared.info("Loaded schedules from local storage")
                self.loadCourseColors { [weak self] courseColors in
                    AppLogger.shared.info("Loaded course colors from local storage")
                    // Only proceed if the colours are available (don't show view unless colours exist)
                    guard let self = self else { return }
                    self.courseColors = courseColors
                    if !schedules.isEmpty {
                        self.checkUpdatesRequired(for: visibleSchedules) {
                            self.loadCourseColors { courseColors in
                                self.courseColors = courseColors
                                if !(visibleSchedules.isEmpty) {
                                    self.status = .loaded
                                } else {
                                    self.status = .hiddenAll
                                }
                            }
                        }
                    }
                    else {
                        self.status = .uninitialized
                    }
                }
            }
        }
        
        
        func onChangeViewType(viewType: BookmarksViewType) -> Void {
            let viewTypeIndex: Int = scheduleViewTypes.firstIndex(of: viewType)!
            preferenceService.setViewType(viewType: viewTypeIndex)
        }
    }
}




// Fileprivate methods
extension BookmarkPage.BookmarkPageViewModel {
    
    fileprivate func checkUpdatesRequired(for bookmarks: [ScheduleStoreModel], completion: @escaping () -> Void) -> Void {
        var updatedBookmarks: [Response.Schedule] = []
        let group = DispatchGroup()
        let calendar = Calendar(identifier: .gregorian)
        let currentDate = Date()
        
        for schedule in bookmarks {
            let difference = calendar.dateComponents([.day, .hour, .minute, .second], from: schedule.lastUpdated, to: currentDate)
            AppLogger.shared.info("Time since last update for schedule with id \(schedule.id) -> \(difference)")
            
            if difference.hour! > 6 {
                AppLogger.shared.info("Schedule with id \(schedule.id) needs to be updated")
                
                group.enter()
                
                self.updateBookmarkedSchedule(for: schedule.id) { fetchedSchedule in
                    updatedBookmarks.append(fetchedSchedule)
                    AppLogger.shared.info("Updated schedule with id -> \(fetchedSchedule.id)")
                    group.leave()
                }
            }
        }
        
        group.notify(queue: DispatchQueue.main) {
            if updatedBookmarks.isEmpty {
                AppLogger.shared.info("Inserting old bookmarks into view")
                self.scheduleListOfDays = bookmarks.removeDuplicateEvents().flatten()
            } else {
                AppLogger.shared.info("Inserting updated bookmarks into view")
                self.scheduleListOfDays = updatedBookmarks.removeDuplicateEvents().flatten()
            }
            completion()
        }
    }
    
    
    // Updates a specific bookmarked schedule based on its lastUpdated attribute
    fileprivate func updateBookmarkedSchedule(for scheduleId: String, completion: @escaping (Response.Schedule) -> Void) -> Void {
        // Get schedule from backend
        self.fetchSchedule(for: scheduleId) { [weak self] (schedule: Response.Schedule) in
            AppLogger.shared.info("Fetched fresh version of schedule from backend")
            // Save schedule in local storage
            guard let self = self else { return }
            // Save bookmarked schedule in local storage which automatically appends
            // new lastUpdated attribute to the saved schedule
            self.saveSchedule(schedule: schedule) {
                AppLogger.shared.info("Saved new version of schedule in local storage")
                // Update course colors to check for potentially new courses in schedule
                self.addColoursToNewCourses(for: schedule) {
                    completion(schedule)
                }
            }
        }
    }
    
    
    fileprivate func addColoursToNewCourses(for schedule: Response.Schedule, completion: @escaping () -> Void) -> Void {
        var availableColors = Set(colors)
        var courseColors = self.courseColors
        let newCoursesWithoutColors = schedule.days.flatMap { $0.events.map { $0.course.id } }.filter { !courseColors.keys.contains($0) }
        for course in newCoursesWithoutColors {
            courseColors[course] = availableColors.popFirst()
        }
        self.saveCourseColors(courseColors: courseColors)
        completion()
        AppLogger.shared.info("Saved new course colors for schedule in local storage")
    }
    
    
    fileprivate func saveCourseColors(courseColors: [String : String]) -> Void {
        self.courseColorService.save(coursesAndColors: courseColors) { courseResult in
            if case .failure(let error) = courseResult {
                self.status = .error
                fatalError(error.localizedDescription)
            } else {
                AppLogger.shared.info("Successfully saved course colors")
            }
        }
    }
    
    
    fileprivate func loadSchedules(completion: @escaping ([ScheduleStoreModel]) -> Void) -> Void {
        DispatchQueue.main.async {
            self.scheduleService.load { [weak self] result in
                guard let self = self else { return }
                switch result {
                case .failure(_):
                    self.status =  .error
                case .success(let bookmarks):
                    completion(bookmarks)
                }
            }
        }
    }
    
    
    fileprivate func saveSchedule(schedule: Response.Schedule, closure: @escaping () -> Void) {
        self.scheduleService.save(schedule: schedule) { scheduleResult in
            DispatchQueue.main.async {
                if case .failure(let error) = scheduleResult {
                    self.status = .error
                    fatalError(error.localizedDescription)
                } else {
                    closure()
                }
            }
        }
    }
    
    
    fileprivate func loadCourseColors(completion: @escaping ([String : String]) -> Void) -> Void {
        self.courseColorService.load { result in
            switch result {
            case .success(let courseColors):
                completion(courseColors)
            case .failure(let failure):
                self.status = .error
                AppLogger.shared.info("Error occured loading colors -> \(failure.localizedDescription)")
            }
        }
    }
    
    
    fileprivate func fetchSchedule(for scheduleId: String, closure: @escaping (Response.Schedule) -> Void) {
        networkManager.get(.schedule(scheduleId: scheduleId, schoolId: String(preferenceService.getDefaultSchool()!.id)), sessionToken: nil) { (result: Result<Response.Schedule, Error>) in
            switch result {
            case .failure(let error):
                AppLogger.shared.info("Encountered error when attempting to update schedule -> \(scheduleId): \(error)")
            case .success(let schedule):
                closure(schedule)
            }
        }
    }
    
    fileprivate func getHiddenBookmarks() -> [String] {
        return self.preferenceService.getBookmarks()?.filter { $0.toggled == false }.map { $0.id } ?? []
    }
    
    fileprivate func filterBookmarks(schedules: [ScheduleStoreModel], hiddenBookmarks: [String]) -> [ScheduleStoreModel] {
        return schedules.filter { schedule in
            !hiddenBookmarks.contains { $0 == schedule.id }
        }
    }
}
