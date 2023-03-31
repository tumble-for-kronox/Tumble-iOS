//
//  HomePageView-ViewModel.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 11/20/22.
//

import Foundation
import SwiftUI

@MainActor final class HomeViewModel: ObservableObject {
    
    @Inject var preferenceService: PreferenceService
    @Inject var userController: UserController
    @Inject var scheduleService: ScheduleService
    @Inject var courseColorService: CourseColorService
    @Inject var networkManager: KronoxManager
    
    @Published var eventSheet: EventDetailsSheetModel? = nil
    @Published var bookmarkedEventsSectionStatus: PageState = .loading
    @Published var newsSectionStatus: PageState = .loading
    @Published var news: Response.NewsItems? = nil
    @Published var eventsForWeek: [Response.Event]? = nil
    @Published var eventsForToday: [Response.Event]? = nil
    @Published var courseColors: CourseAndColorDict? = nil
    
    private let viewModelFactory: ViewModelFactory = ViewModelFactory.shared
    private let dateFormatter = ISO8601DateFormatter()
    
    init() {
        self.getEventsForWeek()
        self.getNews()
    }
    
    func updateViewLocals() -> Void {
        self.getEventsForWeek()
    }
    
    func makeCanvasUrl() -> URL? {
        return URL(string: preferenceService.getCanvasUrl() ?? "")
    }
    
    
    func makeUniversityUrl() -> URL? {
        return URL(string: preferenceService.getUniversityUrl() ?? "")
    }
    
    func generateViewModelEventSheet(event: Response.Event, color: Color) -> EventDetailsSheetViewModel {
        return viewModelFactory.makeViewModelEventDetailsSheet(event: event, color: color)
    }
    
    func updateCourseColors() -> Void {
        self.loadCourseColors { courseColors in
            self.courseColors = courseColors
        }
    }
    
    func getNews() -> Void {
        self.newsSectionStatus = .loading
        let _ = networkManager.get(.news) { [weak self] (result: Result<Response.NewsItems, Response.ErrorMessage>) in
            guard let self = self else { return }
            switch result {
            case .success(let news):
                DispatchQueue.main.async {
                    self.news = news.pick(length: 4) // Show 4 latest items
                    self.newsSectionStatus = .loaded
                }
            case .failure(let failure):
                AppLogger.shared.critical("Failed to retrieve news items: \(failure)")
                DispatchQueue.main.async {
                    self.newsSectionStatus = .error
                }
            }
        }
    }
    
    func getEventsForWeek() {
        self.bookmarkedEventsSectionStatus = .loading
        let hiddenBookmarks: [String] = self.preferenceService.getHiddenBookmarks()
        AppLogger.shared.debug("Fetching events for the week", source: "HomePageViewModel")
        
        scheduleService.load(forCurrentWeek: { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .failure(let error):
                AppLogger.shared.critical("Failed to load schedules for the week: \(error.localizedDescription)", source: "HomePageViewModel")
                self.bookmarkedEventsSectionStatus = .error
            case .success(let events):
                AppLogger.shared.debug("Loaded \(events.count) events for the week", source: "HomePageViewModel")
                self.eventsForToday = self.filterEventsMatchingToday(events: events)
                self.eventsForWeek = events
                self.loadCourseColors { [weak self] courseColors in
                    guard let self = self else { return }
                    DispatchQueue.main.async {
                        self.courseColors = courseColors
                        self.bookmarkedEventsSectionStatus = .loaded
                    }
                }
            }
        }, hiddenBookmarks: hiddenBookmarks)
    }
}

extension HomeViewModel {
    
    fileprivate func filterEventsMatchingToday(events: [Response.Event]) -> [Response.Event] {
        let now = Date()
        let calendar = Calendar.current
        let currentDayOfYear = calendar.ordinality(of: .day, in: .year, for: now) ?? 1
        let filteredEvents = events.filter { [weak self] event in
            guard let self = self else { return false }
            guard let date = self.dateFormatter.date(from: event.from) else { return false }
            let dayOfYear = calendar.ordinality(of: .day, in: .year, for: date) ?? 1
            return dayOfYear == currentDayOfYear
        }

        return filteredEvents
    }
    
    fileprivate func loadCourseColors(completion: @escaping ([String : String]) -> Void) -> Void {
        self.courseColorService.load { [weak self] result in
            guard let self = self else { return }

            switch result {
            case .success(let courseColors):
                completion(courseColors)
            case .failure(let failure):
                DispatchQueue.main.async {
                    self.bookmarkedEventsSectionStatus = .error
                }
                AppLogger.shared.debug("Error occured loading colors -> \(failure.localizedDescription)")
            }
        }
    }
    
}
