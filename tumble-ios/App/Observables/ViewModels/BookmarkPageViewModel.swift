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
    @Published var defaultViewType: BookmarksViewType = .list
    @Published var school: School?
    @Published var eventSheet: EventDetailsSheetModel? = nil
    
    
    init () {
        self.loadBookmarkedSchedules()
        self.defaultViewType = preferenceService.getDefaultViewType()
        self.school = preferenceService.getDefaultSchool()
    }
    
    
    func generateViewModelEventSheet(event: Response.Event, color: Color) -> EventDetailsSheetViewModel {
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
    
    func loadBookmarkedSchedules() {
        loadSchedules { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .failure:
                AppLogger.shared.info("Could not load schedules from local storage")
                DispatchQueue.main.async {
                    self.status = .error
                }
            case .success(let schedules):
                let visibleSchedules = self.filterHiddenBookmarks(schedules: schedules)
                self.loadCourseColors { [weak self] courseColors in
                    guard let self = self else { return }
                    self.courseColors = courseColors
                    guard !schedules.isEmpty else {
                        DispatchQueue.main.async {
                            self.status = .uninitialized
                        }
                        return
                    }
                    self.updateSchedulesIfNeeded(schedules: visibleSchedules) {
                        self.updateViewStatus(schedules: visibleSchedules)
                    }
                }
            }
        }
    }

    private func loadSchedules(completion: @escaping (Result<[ScheduleStoreModel], Error>) -> Void) {
        DispatchQueue.main.async {
            self.scheduleService.load { result in
                completion(result)
            }
        }
    }

    fileprivate func filterHiddenBookmarks(schedules: [ScheduleStoreModel]) -> [ScheduleStoreModel] {
        let hiddenBookmarks = getHiddenBookmarks()
        return schedules.filter { schedule in
            !hiddenBookmarks.contains { $0 == schedule.id }
        }
    }


    private func updateSchedulesIfNeeded(schedules: [ScheduleStoreModel], completion: @escaping () -> Void) {
        updateSchedules(for: schedules, completion: completion)
    }

    private func updateViewStatus(schedules: [ScheduleStoreModel]) {
        DispatchQueue.main.async {
            if schedules.isEmpty {
                self.status = .hiddenAll
            } else {
                self.status = .loaded
            }
        }
    }

    
    
    func onChangeViewType(viewType: BookmarksViewType) -> Void {
        let viewTypeIndex: Int = scheduleViewTypes.firstIndex(of: viewType)!
        preferenceService.setViewType(viewType: viewTypeIndex)
    }
}




// Fileprivate methods
extension BookmarkPageViewModel {
    
    fileprivate func needsUpdate(schedule: ScheduleStoreModel) -> Bool {
        let calendar = Calendar(identifier: .gregorian)
        let currentDate = Date()
        let difference = calendar.dateComponents(
            [.day, .hour, .minute, .second],
            from: schedule.lastUpdated,
            to: currentDate)
        AppLogger.shared.info("Time since last update for schedule with id \(schedule.id) -> \(difference)")
        return difference.hour ?? 0 > 6
    }

    
    fileprivate func updateSchedules(for bookmarks: [ScheduleStoreModel], completion: @escaping () -> Void) {
        var updatedBookmarks = [Response.Schedule]()
        let group = DispatchGroup()
        
        for schedule in bookmarks {
            if needsUpdate(schedule: schedule) {
                AppLogger.shared.info("Schedule with id \(schedule.id) needs to be updated")
                group.enter()
                updateBookmarkedSchedule(for: schedule.id) { result in
                    defer { group.leave() }
                    switch result {
                    case .success(let fetchedSchedule):
                        updatedBookmarks.append(fetchedSchedule)
                        AppLogger.shared.info("Updated schedule with id -> \(fetchedSchedule.id)")
                    case .failure(let error):
                        AppLogger.shared.info("\(error)")
                    }
                }
            }
        }
        group.notify(queue: .main) {
            let uniqueSchedules = updatedBookmarks.removeDuplicateEvents().flatten()
            if uniqueSchedules.isEmpty {
                AppLogger.shared.info("No schedules needed to or could be be updated")
                self.scheduleListOfDays = bookmarks.removeDuplicateEvents().flatten()
            } else {
                AppLogger.shared.info("Amount of updated schedules: \(uniqueSchedules.count)")
                self.scheduleListOfDays = uniqueSchedules
            }
            
            completion()
        }
    }

    // Updates a specific bookmarked schedule based on its lastUpdated attribute
    fileprivate func updateBookmarkedSchedule(
        for scheduleId: String,
        completion: @escaping (Result<Response.Schedule, Error>) -> Void) {
        fetchSchedule(for: scheduleId) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let schedule):
                AppLogger.shared.info("Fetched fresh version of schedule from backend")
                self.saveSchedule(schedule: schedule) {
                    AppLogger.shared.info("Saved new version of schedule in local storage")
                    self.updateCourseColors(for: schedule) {
                        completion(.success(schedule))
                    }
                }
            case .failure(let error):
                AppLogger.shared.info("\(error)")
                completion(.failure(.generic(reason: "\(error)")))
            }
        }
    }

    
    
    fileprivate func updateCourseColors(
        for schedule: Response.Schedule,
        completion: @escaping () -> Void) -> Void {
        var availableColors = Set(colors)
        var courseColors = self.courseColors
        let newCoursesWithoutColors = schedule.days.flatMap {
            $0.events.map { $0.course.id } }.filter { !courseColors.keys.contains($0)
            }
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
        self.courseColorService.load { [weak self] result in
            guard let self = self else { return }

            switch result {
            case .success(let courseColors):
                completion(courseColors)
            case .failure(let failure):
                DispatchQueue.main.async {
                    self.status = .error
                }
                AppLogger.shared.info("Error occured loading colors -> \(failure.localizedDescription)")
            }
        }
    }
    
    
    fileprivate func fetchSchedule(
        for scheduleId: String,
        closure: @escaping (Result<Response.Schedule, Error>) -> Void) {
        networkManager.get(
            .schedule(
                scheduleId: scheduleId,
                schoolId: String(preferenceService.getDefaultSchool()!.id)),
            sessionToken: nil) { (result: Result<Response.Schedule, Response.ErrorMessage>) in
            switch result {
            case .failure(let error):
                AppLogger.shared.info("Encountered error when attempting to update schedule -> \(scheduleId): \(error)")
                closure(.failure(.generic(reason: "Network request timed out")))
            case .success(let schedule):
                closure(.success(schedule))
            }
        }
    }
    
    fileprivate func getHiddenBookmarks() -> [String] {
        return self.preferenceService.getBookmarks()?.filter { $0.toggled == false }.map { $0.id } ?? []
    }
    
    fileprivate func filterBookmarks(
        schedules: [ScheduleStoreModel],
        hiddenBookmarks: [String]) -> [ScheduleStoreModel] {
        return schedules.filter {
            switch $0.id {
            case let id where hiddenBookmarks.contains(id):
                return false
            default:
                return true
            }
        }
    }
}
