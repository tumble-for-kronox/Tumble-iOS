//
//  SearchViewModelExtension.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 2023-04-01.
//

import Foundation

extension SearchViewModel {
    
    // Checks if a schedule based on its programme Id is already in the
    // local storage. if it is, we set the preview button for favoriting
    // to be either save or remove.
    func checkSavedSchedule(programmeId: String, completion: @escaping () -> Void) -> Void {
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
            completion()
        }
    }
    
    
    func handleFetchedSchedule(schedule: Response.Schedule, completion: @escaping () -> Void) -> Void {
        if schedule.isEmpty() {
            self.schedulePreviewStatus = .empty
        } else {
            self.scheduleForPreview = schedule
            self.scheduleListOfDays = schedule.days.toOrderedDays()
            AppLogger.shared.debug("Set schedule local variables")
        }
        DispatchQueue.main.async {
            completion()
        }
    }
    
    
    // Assigns course colors to a schedule if it was found in the local storage.
    // This function should ONLY be called when a schedule is found in the local storage.
    // The purpose is to check for new schedules and add them accordingly
    func assignCourseColorsToSavedSchedule(
        courses: [String : String],
        completion: @escaping ([String : String]) -> Void) -> Void {
            DispatchQueue.global(qos: .userInitiated).async {
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
                DispatchQueue.main.async {
                    completion(courseColors)
                }
            }
    }
    
    
    // API Call to fetch a schedule from backend
    func fetchSchedule(programmeId: String, completion: @escaping (Bool) -> Void) -> Void {
        let _ = networkManager.get(
            .schedule(
                scheduleId: programmeId,
                schoolId: String(school!.id))) { [weak self] (result: Result<Response.Schedule, Response.ErrorMessage>) in
                    guard let self = self else { return }
                    switch result {
                    case .success(let result):
                        AppLogger.shared.debug("Fetched schedule")
                        self.handleFetchedSchedule(schedule: result) {
                            completion(true)
                        }
                    case .failure(let failure):
                        completion(false)
                        self.schedulePreviewStatus = .error
                        self.errorMessagePreview = failure.message.contains("NSURLErrorDomain") ? "Could not contact the server, try again later" : failure.message
                        AppLogger.shared.debug("Encountered failure when attempting to load schedule for programme \(programmeId): \(failure)")
                    }
        }
    }
    
    
    func assignRandomCourseColors(completion: @escaping (Result<[String : String], Error>) -> Void) -> Void {
        DispatchQueue.global(qos: .userInitiated).async {
            if let randomCourseColors = self.scheduleForPreview?.assignCoursesRandomColors() {
                DispatchQueue.main.async {
                    completion(.success(randomCourseColors))
                }
            } else {
                DispatchQueue.main.async {
                    completion(.failure(.generic(reason: "Schedule for preview is null")))
                }
            }
        }
    }
    
    
    func saveSchedule(completion: @escaping (Result<Void, Error>) -> Void) {
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
            case .failure(let failure):
                AppLogger.shared.debug("Fatal failure \(failure)")
                completion(.failure(failure))
            }
        }
    }


    
    
    func removeSchedule(completion: @escaping (Result<Void, Error>) -> Void) -> Void {
        
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
            case .failure(let failure):
                AppLogger.shared.debug("Fatal failure \(failure)")
                DispatchQueue.main.async {
                    completion(.failure(failure))
                }
            }
        }
    }

    func removeCourseColors(completion: @escaping (Result<Void, Error>) -> Void) -> Void {
        courseColorService.remove(removeCourses: (self.scheduleForPreview!.courses())) { result in
            if case .failure(let failure) = result {
                AppLogger.shared.debug("Fatal failure \(failure)")
                DispatchQueue.main.async {
                    completion(.failure(.generic(reason: failure.localizedDescription)))
                }
                return
            } else {
                AppLogger.shared.debug("Removed course colors")
                DispatchQueue.main.async {
                    completion(.success(()))
                }
            }
        }
    }

    
    
    func loadProgrammeCourseColors(completion: @escaping ([String : String]) -> Void) -> Void {
        courseColorService.load { result in
            switch result {
            case .failure:
                AppLogger.shared.critical("Could not load course colors for saved schedule")
            case .success(let courses):
                if !courses.isEmpty {
                    self.assignCourseColorsToSavedSchedule(courses: courses) { newCourseColors in
                        completion(newCourseColors)
                    }
                }
            }
        }
    }
    
    func cancelNotifications(for schedules: [ScheduleStoreModel], with id: String?) -> Void {
        DispatchQueue.global(qos: .background).async { [weak self] in
            guard let self else { return }
            let schedulesToRemove = schedules.filter { $0.id == id }
            let events = schedulesToRemove
                .flatMap { schedule in schedule.days }
                .flatMap { day in day.events }
            events.forEach { event in self.notificationManager.cancelNotification(for: event.id) }
        }
    }
    
    func saveCourseColors(courseColors: [String : String]) -> Void {
        self.courseColorService.save(coursesAndColors: courseColors) { courseResult in
            if case .failure(let failure) = courseResult {
                fatalError(failure.localizedDescription)
            } else {
                AppLogger.shared.debug("Successfully saved course colors")
            }
        }
    }
    
    
    func parseSearchResults(_ results: Response.Search) -> Void {
        var localResults = [Response.Programme]()
        for result in results.items {
            localResults.append(result)
        }
        self.programmeSearchResults = localResults
        self.status = .loaded
    }
    
    func loadSchedules(completion: @escaping ([ScheduleStoreModel]) -> Void) -> Void {
        self.scheduleService.load(completion: {result in
            switch result {
            case .failure:
                return
            case .success(let bookmarks):
                completion(bookmarks)
            }
        })
    }
    
}
