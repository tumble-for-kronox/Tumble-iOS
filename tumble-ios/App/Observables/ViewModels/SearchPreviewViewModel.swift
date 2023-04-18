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
    @ObservedResults(Schedule.self) var schedules
    
    @Inject var preferenceService: PreferenceService
    @Inject var kronoxManager: KronoxManager
    @Inject var notificationManager: NotificationManager
    
    
    let scheduleId: String
    var schedule: Response.Schedule? = nil
    var cancellables = Set<AnyCancellable>()
    
    init(scheduleId: String) {
        self.scheduleId = scheduleId
        setUpDataPublishers()
        loadData()
        getSchedule(programmeId: scheduleId)
    }
    
    func setUpDataPublishers() -> Void {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self else { return }
            let bookmarksSubscription = self.preferenceService.$bookmarks
            let schoolSubscription = self.preferenceService.$schoolId
            
            Publishers.CombineLatest(
                bookmarksSubscription,
                schoolSubscription
            )
            .receive(on: DispatchQueue.main)
            .sink { bookmarks, schoolId in
                self.bookmarks = bookmarks
                self.schoolId = schoolId
            }
            .store(in: &self.cancellables)
        }
    }
    
    func loadData() -> Void {
        schoolId = preferenceService.getDefaultSchool() ?? -1
        bookmarks = preferenceService.getBookmarks()
    }
    
    func getSchedule(programmeId: String) -> Void {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            // Check if schedule is already saved, to set flag
            self.isSaved = self.checkSavedSchedule(programmeId: programmeId)
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
                else if (self.schedules.map { $0.scheduleId }).contains(fetchedSchedule.id) {
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
    
    func bookmark() -> Void {
        buttonState = .loading
        // If the schedule isn't already saved in the local database
        if !isSaved {
            preferenceService.addBookmark(id: scheduleId)
            $schedules.append(schedule!.toRealmSchedule())
            isSaved = true
            buttonState = .saved
        }
        // Otherwise we remove (untoggle) the schedule
        else {
            cancelNotifications(for: Array(schedules), with: scheduleId)
            deleteBookmark(id: scheduleId)
            isSaved = false
            buttonState = .notSaved
        }
    }
    
    private func deleteBookmark(id: String) {
        do {
            let realm = try Realm()
            guard let scheduleToDelete = realm.objects(Schedule.self).filter("scheduleId = %@", id).first else {
                AppLogger.shared.error("Schedule with ID \(id) not found")
                return
            }
            try realm.write {
                realm.delete(scheduleToDelete)
            }
        } catch (let error) {
            AppLogger.shared.debug("Error deleting schedule: \(error)")
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
    func checkSavedSchedule(programmeId: String) -> Bool {
        AppLogger.shared.debug("Checking if schedule is already saved...")
        if schedules.map({ $0.scheduleId }).contains(programmeId) {
            return true
        }
        return false
    }
    
    func cancelNotifications(for schedules: [Schedule], with id: String?) -> Void {
        DispatchQueue.global(qos: .background).async { [weak self] in
            guard let self else { return }
            let schedulesToRemove = schedules.filter { $0.scheduleId == id }
            let events = schedulesToRemove
                .flatMap { schedule in schedule.days }
                .flatMap { day in day.events }
            events.forEach { event in self.notificationManager.cancelNotification(for: event.eventId) }
        }
    }

}
