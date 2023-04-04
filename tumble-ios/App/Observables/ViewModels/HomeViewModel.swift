//
//  HomePageView-ViewModel.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 11/20/22.
//

import Foundation
import SwiftUI

struct WeekEventCardModel: Identifiable {
    var id: UUID = UUID()
    var offset: CGFloat = 0
    var event: Response.Event
}

enum HomeStatus {
    case available
    case notAvailable
    case noBookmarks
    case loading
    case error
}

@MainActor final class HomeViewModel: ObservableObject {
    
    @Inject var preferenceService: PreferenceService
    @Inject var userController: UserController
    @Inject var scheduleService: ScheduleService
    @Inject var courseColorService: CourseColorService
    @Inject var networkManager: KronoxManager
    @Inject var schoolManager: SchoolManager
    
    @Published var eventSheet: EventDetailsSheetModel? = nil
    @Published var todayEventsSectionStatus: GenericPageStatus = .loading
    @Published var nextEventSectionStatus: GenericPageStatus = .loading
    @Published var newsSectionStatus: GenericPageStatus = .loading
    @Published var news: Response.NewsItems? = nil
    @Published var eventsForWeek: [WeekEventCardModel] = []
    @Published var nextClass: Response.Event? = nil
    @Published var eventsForToday: [WeekEventCardModel] = []
    @Published var courseColors: CourseAndColorDict? = nil
    @Published var swipedCards: Int = 0
    @Published var homeStatus: HomeStatus = .loading
    
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
                    print(news.count)
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
        self.todayEventsSectionStatus = .loading
        self.nextEventSectionStatus = .loading
        self.homeStatus = .loading
        let hiddenBookmarks: [String] = self.preferenceService.getHiddenBookmarks()
        AppLogger.shared.debug("Fetching events for the week", source: "HomePageViewModel")
        
        scheduleService.load(forCurrentWeek: { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .failure(let error):
                AppLogger.shared.critical("Failed to load schedules for the week: \(error.localizedDescription)", source: "HomePageViewModel")
                self.todayEventsSectionStatus = .error
                self.nextEventSectionStatus = .error
                self.homeStatus = .error
            case .success(let events):
                AppLogger.shared.debug("Loaded \(events.count) events for the week", source: "HomePageViewModel")
                // If no events are available,
                // schedule is clear for the week or the user
                // has nothing saved yet
                if events.isEmpty {
                    if let bookmarks = self.preferenceService.getBookmarks() {
                        if bookmarks.isEmpty {
                            self.homeStatus = .noBookmarks
                            return
                        }
                    }
                    self.homeStatus = .notAvailable
                    return
                }
                self.createDayCards(events:
                    self.filterEventsMatchingToday(events: events)
                )
                self.nextClass = self.findNextUpcomingEvent(events: events)
                self.loadCourseColors { courseColors in
                    self.courseColors = courseColors
                    self.todayEventsSectionStatus = .loaded
                    self.nextEventSectionStatus = .loaded
                    self.homeStatus = .available
                }
            }
        }, hiddenBookmarks: hiddenBookmarks)
    }
    
    func createDayCards(events: [Response.Event]) -> Void {
        let weekEventCards = events.map {
            return WeekEventCardModel(event: $0)
        }
        self.eventsForToday = weekEventCards.reversed()
    }
}
