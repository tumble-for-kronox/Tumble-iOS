//
//  BookmarksViewModelExtension.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 2023-04-01.
//

import Foundation

extension BookmarksViewModel {
    
    func needsUpdate(schedule: ScheduleData) -> Bool {
        let calendar = Calendar(identifier: .gregorian)
        let currentDate = Date()
        let difference = calendar.dateComponents(
            [.day, .hour, .minute, .second],
            from: schedule.lastUpdated,
            to: currentDate)
        if let hours = difference.hour {
            AppLogger.shared.debug("Time in hours since last update for schedule with id \(schedule.id) -> \(hours)")
            return hours >= 3
        }
        return true
    }

    
    func updateSchedules(for bookmarks: [ScheduleData], completion: @escaping () -> Void) {
        let group = DispatchGroup()
        var updatedBookmarks = [Response.Schedule]()
        var schedulesToBeUpdated = [ScheduleData]()
        
        for schedule in bookmarks {
            if needsUpdate(schedule: schedule) {
                AppLogger.shared.debug("Schedule with id \(schedule.id) needs to be updated")
                schedulesToBeUpdated.append(schedule)
            }
        }
        
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self else { return }
            let results = schedulesToBeUpdated.map { schedule -> Result<Response.Schedule, Error> in
                group.enter()
                defer { group.leave() }
                let semaphore = DispatchSemaphore(value: 0)
                var result: Result<Response.Schedule, Error>?
                
                self.updateBookmarkedSchedule(for: schedule.id) { fetchResult in
                    result = fetchResult
                    semaphore.signal()
                }
                
                semaphore.wait()
                return result!
            }
            
            updatedBookmarks = results.compactMap {
                if case .success(let fetchedSchedule) = $0 {
                    return fetchedSchedule
                }
                return nil
            }
            
            group.notify(queue: DispatchQueue.main) {
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
            case .failure(let failure):
                AppLogger.shared.debug("\(failure)")
                completion(.failure(.generic(reason: "\(failure)")))
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
            if case .failure(let failure) = courseResult {
                self.status = .error
                fatalError(failure.localizedDescription)
            } else {
                AppLogger.shared.debug("Successfully saved course colors")
            }
        }
    }
    
    
    func saveSchedule(schedule: Response.Schedule, completion: @escaping () -> Void) {
        self.scheduleService.save(schedule: schedule) { scheduleResult in
            DispatchQueue.main.async {
                if case .failure(let failure) = scheduleResult {
                    self.status = .error
                    fatalError(failure.localizedDescription)
                } else {
                    completion()
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
                self.status = .error
                AppLogger.shared.debug("Error occured loading colors -> \(failure.localizedDescription)")
                return
            }
        }
    }
    
    
    func fetchSchedule(
        for scheduleId: String,
        completion: @escaping (Result<Response.Schedule, Error>) -> Void) {
        let _ = kronoxManager.get(
            .schedule(
                scheduleId: scheduleId,
                schoolId: String(preferenceService.getDefaultSchool()!))) { (result: Result<Response.Schedule, Response.ErrorMessage>) in
            switch result {
            case .failure(let failure):
                AppLogger.shared.debug("Encountered failure when attempting to update schedule -> \(scheduleId): \(failure)")
                completion(.failure(.generic(reason: "Network request timed out")))
            case .success(let schedule):
                completion(.success(schedule))
            }
        }
    }
    
    func filterBookmarks(
        schedules: [ScheduleData],
        hiddenBookmarks: [String]) -> [ScheduleData] {
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
