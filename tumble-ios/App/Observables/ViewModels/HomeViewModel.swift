//
//  HomePageView-ViewModel.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 11/20/22.
//

import Foundation
import SwiftUI
import Combine

@MainActor final class HomeViewModel: ObservableObject {
    
    @Inject var preferenceService: PreferenceService
    @Inject var userController: UserController
    @Inject var scheduleService: ScheduleService
    @Inject var courseColorService: CourseColorService
    @Inject var kronoxManager: KronoxManager
    
    @Published var newsSectionStatus: GenericPageStatus = .loading
    @Published var news: Response.NewsItems? = nil
    @Published var courseColors: CourseAndColorDict = [:]
    @Published var swipedCards: Int = 0
    @Published var status: HomeStatus = .loading
    @Published var schedules: [ScheduleData] = []
    @Published var eventsForToday: [WeekEventCardModel] = []
    @Published var nextClass: Response.Event? = nil
    @Published var bookmarks: [Bookmark]? {
        didSet {
            loadEvents()
        }
    }
    
    private let viewModelFactory: ViewModelFactory = ViewModelFactory.shared
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        initialisePipelines()
        getNews()
    }
    
    func initialisePipelines() -> Void {
        // Set up publisher to update schedules when data store is updated
        scheduleService.$schedules
            .sink { [weak self] schedules in
                guard let self else { return }
                self.schedules = schedules
                loadEvents()
            }
            .store(in: &cancellables)
        courseColorService.$courseColors
            .assign(to: \.courseColors, on: self)
            .store(in: &cancellables)
        scheduleService.$executionStatus
            .sink { [weak self] executionStatus in
                guard let self else { return }
                self.handleDataExecutionStatus(executionStatus: executionStatus)
            }
            .store(in: &cancellables)
        preferenceService.$bookmarks
            .assign(to: \.bookmarks, on: self)
            .store(in: &cancellables)
    }
    
    func handleDataExecutionStatus(executionStatus: ExecutionStatus) -> Void {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            switch executionStatus {
            case .executing:
                self.status = .loading
            case .error:
                self.status = .error
            case .available:
                if schedules.isEmpty {
                    self.status = .noBookmarks
                } else {
                    let hiddenBookmarks = bookmarks?.filter { !$0.toggled }.map { $0.id } ?? []
                    if filterHiddenBookmarks(schedules: schedules, hiddenBookmarks: hiddenBookmarks).isEmpty {
                        self.status = .notAvailable
                    } else {
                        self.status = .available
                    }
                }
            }
        }
    }
    
    func getNews() -> Void {
        newsSectionStatus = .loading
        let _ = kronoxManager.get(.news) { [weak self] (result: Result<Response.NewsItems, Response.ErrorMessage>) in
            guard let self = self else { return }
            switch result {
            case .success(let news):
                self.news = news
                self.newsSectionStatus = .loaded
            case .failure(let failure):
                AppLogger.shared.critical("Failed to retrieve news items: \(failure)")
                self.newsSectionStatus = .error
            }
        }
    }
    
    func loadEvents() {
        let eventsForWeek = loadEventsForWeek()
        nextClass = findNextUpcomingEvent()
        eventsForToday = createDayCards(events: filterEventsMatchingToday(events: eventsForWeek))
        if schedules.isEmpty {
            status = .noBookmarks
        } else if nextClass == nil && eventsForToday.isEmpty {
            status = .notAvailable
        } else {
            status = .available
        }
    }
    
    func createDayCards(events: [Response.Event]) -> [WeekEventCardModel] {
        let weekEventCards = events.map {
            return WeekEventCardModel(event: $0)
        }
        return weekEventCards.reversed()
    }
    
    func findNextUpcomingEvent() -> Response.Event? {
        let hiddenBookmarks = bookmarks?.filter { !$0.toggled }.map { $0.id } ?? []
        let days: [Response.Day] = schedules.filter {!hiddenBookmarks.contains($0.id)}.flatMap { $0.days }
        let events: [Response.Event] = days.flatMap { $0.events }
        let sortedEvents = events.sorted()
        let now = Date()
        
        // Find the most recent upcoming event that is not today
        if let nextEvent = sortedEvents.first(where: { isoDateFormatter.date(from: $0.from)! > now }) {
            if Calendar.current.isDate(now, inSameDayAs: isoDateFormatter.date(from: nextEvent.from)!) {
                // If the next event is today, find the next upcoming event that is not today
                if let nextNonTodayEvent = sortedEvents.first(where: {
                    !Calendar.current.isDate(now, inSameDayAs: isoDateFormatter.date(from: $0.from)!) &&
                    isoDateFormatter.date(from: $0.from)! > now
                }) {
                    return nextNonTodayEvent
                } else {
                    return nil
                }
            } else {
                return nextEvent
            }
        }
        return nil
    }
    
}
