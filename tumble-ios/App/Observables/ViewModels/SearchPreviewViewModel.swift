//
//  SearchPreviewViewModel.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 4/14/23.
//

import Foundation
import Combine

struct SearchPreviewModel: Identifiable {
    let id: String
}

final class SearchPreviewViewModel: ObservableObject {
    
    @Published var isSaved = false
    @Published var status: SchedulePreviewStatus = .loading
    @Published var schedules: [ScheduleData] = []
    @Published var courseColors: CourseAndColorDict = [:]
    @Published var bookmarks: [Bookmark]?
    @Published var schoolId: Int = -1
    @Published var errorMessage: String? = nil
    @Published var buttonState: ButtonState = .loading
    @Published var courseColorsForPreview: CourseAndColorDict = [:]
    
    @Inject var scheduleService: ScheduleService
    @Inject var courseColorService: CourseColorService
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
            let schedulesSubscription = scheduleService.$schedules
            let courseColorsSubscription = courseColorService.$courseColors
            let bookmarksSubscription = preferenceService.$bookmarks
            let schoolSubscription = preferenceService.$schoolId
            
            Publishers.CombineLatest4(
                schedulesSubscription,
                courseColorsSubscription,
                bookmarksSubscription,
                schoolSubscription
            )
            .receive(on: DispatchQueue.main)
            .sink { schedules, courseColors, bookmarks, schoolId in
                self.schedules = schedules
                self.courseColors = courseColors
                self.bookmarks = bookmarks
                self.schoolId = schoolId
            }
            .store(in: &cancellables)
        }
    }
    
    func loadData() -> Void {
        schoolId = preferenceService.getDefaultSchool() ?? -1
        schedules = scheduleService.getSchedules()
        courseColors = courseColorService.getCourseColors()
        bookmarks = preferenceService.getBookmarks()
    }
    
    func getSchedule(programmeId: String) -> Void {
        
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            // Check if schedule is already saved, to set flag
            isSaved = checkSavedSchedule(programmeId: programmeId)
        }
        // Always get latest schedule
        fetchSchedule(programmeId: programmeId) { [weak self] result in
            guard let self else { return }
            switch result {
            case .success(let fetchedSchedule):
                if fetchedSchedule.isScheduleEmpty() {
                    status = .empty
                    buttonState = .disabled
                }
                else if (schedules.map { $0.id }).contains(fetchedSchedule.id) {
                    isSaved = true
                    buttonState = .saved
                    schedule = fetchedSchedule
                    let courses = fetchedSchedule.courses()
                    courseColorsForPreview = courseColors.filter { courses.contains($0.key) }
                    status = .loaded
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
                status = .error
                errorMessage = failure.message.contains("NSURLErrorDomain") ? "Could not contact the server, try again later" : failure.message
            }
        }
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
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self else { return }
            // If the schedule isn't already saved in the local database
            if !isSaved {
                scheduleService.save(schedule: schedule!, completion: { result in
                    switch result {
                    case .success:
                        self.preferenceService.addBookmark(id: self.schedule!.id)
                        self.courseColorService.save(
                            coursesAndColors: self.courseColorsForPreview, completion: { result in
                            switch result {
                            case .success:
                                self.buttonState = .saved
                                self.isSaved = true
                            case .failure:
                                self.buttonState = .notSaved
                                self.status = .error
                            }
                        })
                    case .failure:
                        self.status = .error
                    }
                })
            }
            // Otherwise we remove (untoggle) the schedule
            else {
                cancelNotifications(for: schedules, with: schedule?.id)
                scheduleService.remove(scheduleId: schedule!.id, completion: { [weak self] result in
                    guard let self else { return }
                    switch result {
                    case .success:
                        self.preferenceService.removeBookmark(id: self.schedule!.id)
                        self.courseColorService.remove(
                            removeCourses: self.schedule!.courses(),
                            completion: { result in
                                switch result {
                                case .success:
                                    AppLogger.shared.info("Removed schedule \(self.schedule!.id)")
                                    self.buttonState = .notSaved
                                    self.isSaved = false
                                case .failure:
                                    AppLogger.shared.error("Failed to remove course colors for schedule")
                                    self.buttonState = .saved
                                    self.status = .error
                                }
                            })
                    case .failure:
                        AppLogger.shared.error("Failed to remove schedule")
                        self.status = .error
                    }
                })
            }
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
        if schedules.map({ $0.id }).contains(programmeId) {
            return true
        }
        return false
    }
    
    func cancelNotifications(for schedules: [ScheduleData], with id: String?) -> Void {
        DispatchQueue.global(qos: .background).async { [weak self] in
            guard let self else { return }
            let schedulesToRemove = schedules.filter { $0.id == id }
            let events = schedulesToRemove
                .flatMap { schedule in schedule.days }
                .flatMap { day in day.events }
            events.forEach { event in self.notificationManager.cancelNotification(for: event.id) }
        }
    }

}
