//
//  SearchPreviewViewModel.swift
//  Tumble
//
//  Created by Adis Veletanlic on 4/14/23.
//

import Combine
import Foundation
import RealmSwift

struct SearchPreviewModel: Identifiable {
    let id: UUID = .init()
    let scheduleId: String
    let schoolId: String
}

final class SearchPreviewViewModel: ObservableObject {
    @Published var isSaved = false
    @Published var status: SchedulePreviewStatus = .loading
    @Published var bookmarks: [Bookmark]?
    @Published var errorMessage: String? = nil
    @Published var buttonState: ButtonState = .loading
    @Published var courseColorsForPreview: [String: String] = [:]
    
    @Inject var preferenceService: PreferenceService
    @Inject var kronoxManager: KronoxManager
    @Inject var notificationManager: NotificationManager
    @Inject var schoolManager: SchoolManager
    
    var schedule: Response.Schedule? = nil
    private lazy var schools: [School] = schoolManager.getSchools()
    
    func getSchedule(
        programmeId: String,
        schoolId: String,
        schedules: [Schedule]
    ) {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            // Check if schedule is already saved, to set flag
            self.isSaved = self.checkSavedSchedule(programmeId: programmeId, schedules: schedules)
        }
        // Always get latest schedule
        fetchSchedule(programmeId: programmeId, schoolId: schoolId) { [weak self] result in
            guard let self else { return }
            switch result {
            case .success(let fetchedSchedule):
                if fetchedSchedule.isScheduleEmpty() {
                    self.status = .empty
                    self.buttonState = .disabled
                } else if (schedules.map { $0.scheduleId }).contains(fetchedSchedule.id) {
                    self.isSaved = true
                    self.buttonState = .saved
                    self.schedule = fetchedSchedule
                    self.courseColorsForPreview = self.getCourseColors()
                    self.status = .loaded
                } else {
                    self.assignRandomCourseColors(
                        schedule: fetchedSchedule
                    ) { [weak self] (result: Result<[String: String], Error>) in
                        guard let self = self else { return }
                        switch result {
                        case .success(let courseColors):
                            // Assign possibly updated course colors
                            self.courseColorsForPreview = courseColors
                            self.schedule = fetchedSchedule
                            self.buttonState = .notSaved
                            self.status = .loaded
                        case .failure(let failure):
                            AppLogger.shared.debug("\(failure)")
                            self.status = .error
                        }
                    }
                }
            case .failure(let failure):
                self.status = .error
                self.errorMessage = failure.message.contains("NSURLErrorDomain") ? "Could not contact the server, try again later" : failure.message
            }
        }
    }
    
    func scheduleRequiresAuth(schoolId: String) -> Bool {
        return schools.first(where: { $0.id == Int(schoolId) })?.loginRq ?? false
    }
    
    func getCourseColors() -> [String: String] {
        let realm = try! Realm()
        let courses = realm.objects(Course.self)
        var courseColors: [String: String] = [:]
        for course in courses {
            courseColors[course.courseId] = course.color
        }
        return courseColors
    }

    // API Call to fetch a schedule from backend
    func fetchSchedule(
        programmeId: String,
        schoolId: String,
        completion: @escaping (Result<Response.Schedule, Response.ErrorMessage>) -> Void
    ) {
        let _ = kronoxManager.get(
            .schedule(
                scheduleId: programmeId,
                schoolId: schoolId
            )) {
                (result: Result<Response.Schedule, Response.ErrorMessage>) in
                switch result {
                case .success(let schedule):
                    completion(.success(schedule))
                case .failure(let failure):
                    completion(.failure(failure))
                }
            }
    }
    
    func bookmark(id: String, schedules: [Schedule]) {
        buttonState = .loading
        // If the schedule isn't already saved in the local database
        if !isSaved {
            isSaved = true
            buttonState = .saved
        }
        // Otherwise we remove (untoggle) the schedule
        else {
            let schedulesToRemove = schedules.filter { $0.scheduleId == id }
            let events = schedulesToRemove
                .flatMap { schedule in schedule.days }
                .flatMap { day in day.events }
            events.forEach { event in self.notificationManager.cancelNotification(for: event.eventId) }
            isSaved = false
            buttonState = .notSaved
        }
    }
}

extension SearchPreviewViewModel {
    func assignRandomCourseColors(
        schedule: Response.Schedule,
        completion: @escaping (Result<[String: String], Error>) -> Void
    ) {
        DispatchQueue.global(qos: .userInitiated).async {
            let randomCourseColors = schedule.assignCoursesRandomColors()
            DispatchQueue.main.async {
                completion(.success(randomCourseColors))
            }
        }
    }
    
    // Checks if a schedule based on its programme Id is already in the
    // local storage. if it is, we set the preview button for favoriting
    // to be either save or remove.
    func checkSavedSchedule(programmeId: String, schedules: [Schedule]) -> Bool {
        AppLogger.shared.debug("Checking if schedule is already saved...")
        if schedules.map({ $0.scheduleId }).contains(programmeId) {
            return true
        }
        return false
    }
}
