//
//  BookmarksViewModelExtension.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 2023-04-01.
//

import Foundation

extension BookmarksViewModel {
    
    func needsUpdate(schedule: ScheduleStoreModel) -> Bool {
        let calendar = Calendar(identifier: .gregorian)
        let currentDate = Date()
        let difference = calendar.dateComponents(
            [.day, .hour, .minute, .second],
            from: schedule.lastUpdated,
            to: currentDate)
        if let hours = difference.hour {
            AppLogger.shared.debug("Time in hours since last update for schedule with id \(schedule.id) -> \(hours)")
            return hours >= 6
        }
        return true
    }

    
    func updateSchedules(for bookmarks: [ScheduleStoreModel], completion: @escaping () -> Void) {
        var updatedBookmarks = [Response.Schedule]()
        let group = DispatchGroup()
        
        for schedule in bookmarks {
            if needsUpdate(schedule: schedule) {
                AppLogger.shared.debug("Schedule with id \(schedule.id) needs to be updated")
                group.enter()
                updateBookmarkedSchedule(for: schedule.id) { result in
                    defer { group.leave() }
                    switch result {
                    case .success(let fetchedSchedule):
                        updatedBookmarks.append(fetchedSchedule)
                        AppLogger.shared.debug("Updated schedule with id -> \(fetchedSchedule.id)")
                    case .failure(let error):
                        AppLogger.shared.debug("\(error)")
                    }
                }
            }
        }
        group.notify(queue: .main) {
            let uniqueEvents = updatedBookmarks.removeDuplicateEvents().flatten()
            if uniqueEvents.isEmpty {
                AppLogger.shared.debug("No schedules needed to or could be be updated")
                self.scheduleListOfDays = bookmarks.removeDuplicateEvents().flatten()
            } else {
                AppLogger.shared.debug("Amount of updated events: \(uniqueEvents.count)")
                self.scheduleListOfDays = uniqueEvents
            }
            
            completion()
        }
    }

    // Updates a specific bookmarked schedule based on its lastUpdated attribute
    func updateBookmarkedSchedule(
        for scheduleId: String,
        completion: @escaping (Result<Response.Schedule, Error>) -> Void) {
        fetchSchedule(for: scheduleId) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let schedule):
                AppLogger.shared.debug("Fetched fresh version of schedule from backend")
                self.saveSchedule(schedule: schedule) {
                    AppLogger.shared.debug("Saved new version of schedule in local storage")
                    self.updateCourseColors(for: schedule) {
                        completion(.success(schedule))
                    }
                }
            case .failure(let error):
                AppLogger.shared.debug("\(error)")
                completion(.failure(.generic(reason: "\(error)")))
            }
        }
    }

    
    
    func updateCourseColors(
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
        AppLogger.shared.debug("Saved new course colors for schedule in local storage")
    }
    
    
    func saveCourseColors(courseColors: [String : String]) -> Void {
        self.courseColorService.save(coursesAndColors: courseColors) { courseResult in
            if case .failure(let error) = courseResult {
                self.status = .error
                fatalError(error.localizedDescription)
            } else {
                AppLogger.shared.debug("Successfully saved course colors")
            }
        }
    }
    
    
    func saveSchedule(schedule: Response.Schedule, closure: @escaping () -> Void) {
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
    
    
    func loadCourseColors(completion: @escaping ([String : String]) -> Void) -> Void {
        self.courseColorService.load { [weak self] result in
            guard let self = self else { return }

            switch result {
            case .success(let courseColors):
                completion(courseColors)
            case .failure(let failure):
                DispatchQueue.main.async {
                    self.status = .error
                }
                AppLogger.shared.debug("Error occured loading colors -> \(failure.localizedDescription)")
            }
        }
    }
    
    
    func fetchSchedule(
        for scheduleId: String,
        closure: @escaping (Result<Response.Schedule, Error>) -> Void) {
        let _ = networkManager.get(
            .schedule(
                scheduleId: scheduleId,
                schoolId: String(preferenceService.getDefaultSchool()!))) { (result: Result<Response.Schedule, Response.ErrorMessage>) in
            switch result {
            case .failure(let error):
                AppLogger.shared.debug("Encountered error when attempting to update schedule -> \(scheduleId): \(error)")
                closure(.failure(.generic(reason: "Network request timed out")))
            case .success(let schedule):
                closure(.success(schedule))
            }
        }
    }
    
    func filterBookmarks(
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
