//
//  SearchPreviewViewModel.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 4/14/23.
//

import Foundation
import Combine
import RealmSwift

struct SearchPreviewModel: Identifiable {
    let id: String
}

final class SearchPreviewViewModel: ObservableObject {
    
    @Published var isSaved = false
    @Published var status: SchedulePreviewStatus = .loading
    @Published var bookmarks: [Bookmark]?
    @Published var schoolId: Int = -1
    @Published var errorMessage: String? = nil
    @Published var buttonState: ButtonState = .loading
    @Published var courseColorsForPreview: [String : String] = [:]
    
    @Inject var preferenceService: PreferenceService
    @Inject var kronoxManager: KronoxManager
    @Inject var notificationManager: NotificationManager
    
    
    let scheduleId: String
    var schedule: Response.Schedule? = nil
    private var cancellables = Set<AnyCancellable>()
    
    init(scheduleId: String) {
        self.scheduleId = scheduleId
        setUpDataPublishers()
        loadData()
    }
    
    func setUpDataPublishers() -> Void {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self else { return }
            let schoolSubscription = self.preferenceService.$schoolId
            
            schoolSubscription
            .receive(on: DispatchQueue.main)
            .sink { schoolId in
                self.schoolId = schoolId
            }
            .store(in: &self.cancellables)
        }
    }
    
    func loadData() -> Void {
        schoolId = preferenceService.getDefaultSchool() ?? -1
    }
    
    func getSchedule(programmeId: String, schedules: [Schedule]) -> Void {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            // Check if schedule is already saved, to set flag
            self.isSaved = self.checkSavedSchedule(programmeId: programmeId, schedules: schedules)
        }
        // Always get latest schedule
        fetchSchedule(programmeId: programmeId) { [weak self] result in
            guard let self else { return }
            switch result {
            case .success(let fetchedSchedule):
                if fetchedSchedule.isScheduleEmpty() {
                    self.status = .empty
                    self.buttonState = .disabled
                }
                else if (schedules.map { $0.scheduleId }).contains(fetchedSchedule.id) {
                    self.isSaved = true
                    self.buttonState = .saved
                    self.schedule = fetchedSchedule
                    self.courseColorsForPreview = self.getCourseColors()
                    self.status = .loaded
                } else {
                    self.assignRandomCourseColors(
                        schedule: fetchedSchedule
                    ) { [weak self] (result: Result<[String : String], Error>) in
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
    
    func getCourseColors() -> [String : String] {
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
        completion: @escaping (Result<Response.Schedule, Response.ErrorMessage>) -> Void) -> Void {
        let _ = kronoxManager.get(
            .schedule(
                scheduleId: programmeId,
                schoolId: String(schoolId))) {
                    (result: Result<Response.Schedule, Response.ErrorMessage>) in
                    switch result {
                    case .success(let schedule):
                        completion(.success(schedule))
                    case .failure(let failure):
                        completion(.failure(failure))
                }
        }
    }
    
    func bookmark(id: String, schedules: [Schedule]) -> Void {
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
        completion: @escaping (Result<[String : String], Error>) -> Void) -> Void {
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
