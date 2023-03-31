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
    func checkSavedSchedule(programmeId: String, closure: @escaping () -> Void) -> Void {
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
    
    
    func handleFetchedSchedule(schedule: Response.Schedule, closure: @escaping () -> Void) -> Void {
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
    func assignCourseColorsToSavedSchedule(
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
    func fetchSchedule(programmeId: String, closure: @escaping (Bool) -> Void) -> Void {
        let _ = networkManager.get(
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
                            self.errorMessagePreview = error.message.contains("NSURLErrorDomain") ? "Could not contact the server" : error.message
                            AppLogger.shared.debug("Encountered error when attempting to load schedule for programme \(programmeId): \(error)")
                        }
                    }
        }
    }
    
    
    func assignRandomCourseColors(closure: @escaping (Result<[String : String], Error>) -> Void) -> Void {
        if let randomCourseColors = self.scheduleForPreview?.assignCoursesRandomColors() {
            closure(.success(randomCourseColors))
        } else {
            closure(.failure(.generic(reason: "Schedule for preview is null")))
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
            case .failure(let error):
                AppLogger.shared.debug("Fatal error \(error)")
                completion(.failure(error))
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
            case .failure(let error):
                AppLogger.shared.debug("Fatal error \(error)")
                completion(.failure(error))
            }
        }
    }

    func removeCourseColors(completion: @escaping (Result<Void, Error>) -> Void) -> Void {
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

    
    
    func loadProgrammeCourseColors(closure: @escaping ([String : String]) -> Void) -> Void {
        courseColorService.load { result in
            DispatchQueue.main.async {
                switch result {
                case .failure(_):
                    AppLogger.shared.critical("Could not load course colors for saved schedule")
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
    
    
    func saveCourseColors(courseColors: [String : String]) -> Void {
        self.courseColorService.save(coursesAndColors: courseColors) { courseResult in
            if case .failure(let error) = courseResult {
                fatalError(error.localizedDescription)
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
        DispatchQueue.main.async {
            self.programmeSearchResults = localResults
            self.status = .loaded
        }
    }
    
    func loadSchedules(completion: @escaping ([ScheduleStoreModel]) -> Void) -> Void {
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
