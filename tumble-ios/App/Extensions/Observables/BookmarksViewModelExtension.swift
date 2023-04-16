//
//  BookmarksViewModelExtension.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 2023-04-01.
//

import Foundation

extension BookmarksViewModel {
    
    func updateSchedules(for bookmarks: [ScheduleData], completion: @escaping () -> Void) {
        let group = DispatchGroup()
        var schedulesToBeUpdated = [ScheduleData]()
        
        for schedule in bookmarks {
            if scheduleNeedsUpdate(schedule: schedule) {
                AppLogger.shared.debug("Schedule with id \(schedule.id) needs to be updated")
                schedulesToBeUpdated.append(schedule)
            }
        }
        
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self else { return }
            let _ = schedulesToBeUpdated.map { schedule -> Result<Response.Schedule, Error> in
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
            group.notify(queue: DispatchQueue.main) {
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
    
    
    func fetchSchedule(
        for scheduleId: String,
        completion: @escaping (Result<Response.Schedule, Error>) -> Void) {
        let _ = kronoxManager.get(
            .schedule(
                scheduleId: scheduleId,
                schoolId: String(preferenceService.getDefaultSchool()!))) {
                    (result: Result<Response.Schedule, Response.ErrorMessage>) in
            switch result {
            case .failure(let failure):
                AppLogger.shared.debug("Encountered failure when attempting to update schedule -> \(scheduleId): \(failure)")
                completion(.failure(.generic(reason: "Network request timed out")))
            case .success(let schedule):
                completion(.success(schedule))
            }
        }
    }
    
}
