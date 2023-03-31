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
    @Inject var schoolManager: SchoolManager
    
    @Published var eventSheet: EventDetailsSheetModel? = nil
    @Published var bookmarkedEventsSectionStatus: GenericPageStatus = .loading
    @Published var newsSectionStatus: GenericPageStatus = .loading
    @Published var news: Response.NewsItems? = nil
    @Published var eventsForWeek: [Response.Event]? = nil
    @Published var eventsForToday: [Response.Event]? = nil
    @Published var courseColors: CourseAndColorDict? = nil
    
    private let viewModelFactory: ViewModelFactory = ViewModelFactory.shared
    
    init() {
        self.getEventsForWeek()
        self.getNews()
    }
    
    var ladokUrl: String {
        return schoolManager.getLadokUrl()
    }
    
    func updateViewLocals() -> Void {
        self.getEventsForWeek()
    }
    
    func makeCanvasUrl() -> URL? {
        return URL(string: preferenceService.getCanvasUrl(schools: schoolManager.getSchools()) ?? "")
    }
    
    
    func makeUniversityUrl() -> URL? {
        return URL(string: preferenceService.getUniversityUrl(schools: schoolManager.getSchools()) ?? "")
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
