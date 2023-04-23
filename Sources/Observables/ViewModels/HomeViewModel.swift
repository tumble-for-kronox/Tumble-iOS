//
//  HomeViewModel.swift
//  Tumble
//
//  Created by Adis Veletanlic on 11/20/22.
//

import Combine
import Foundation
import RealmSwift
import SwiftUI

final class HomeViewModel: ObservableObject {
    @Inject var preferenceService: PreferenceService
    @Inject var userController: UserController
    @Inject var kronoxManager: KronoxManager
    
    @Published var newsSectionStatus: GenericPageStatus = .loading
    @Published var news: Response.NewsItems? = nil
    @Published var swipedCards: Int = 0
    @Published var status: HomeStatus = .loading
    @Published var eventsForToday: [WeekEventCardModel] = .init()
    @Published var nextClass: Event? = nil
    
    private let viewModelFactory: ViewModelFactory = .shared
    var schedulesToken: NotificationToken?
    
    init() {
        getNews()
        let realm = try! Realm()
        let schedules = realm.objects(Schedule.self)
        schedulesToken = schedules.observe { [weak self] changes in
            guard let self = self else { return }
            switch changes {
            case .initial(let results), .update(let results, _, _, _):
                self.status = .loading
                self.createEventsForToday(schedules: Array(results))
                self.nextClass = self.findNextUpcomingEvent(schedules: Array(schedules))
                self.status = .available
            case .error:
                self.status = .error
            }
        }
    }
    
    func getNews() {
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
    
    func createDayCards(events: [Event]) {
        let weekEventCards = filterEventsMatchingToday(events: events).map {
            WeekEventCardModel(event: $0)
        }
        eventsForToday = weekEventCards.reversed()
    }
    
    func findNextUpcomingEvent(schedules: [Schedule]) -> Event? {
        let hiddenBookmarks = schedules.filter { !$0.toggled }.map { $0.scheduleId }
        let days: [Day] = schedules.filter { !hiddenBookmarks.contains($0.scheduleId) }.flatMap { $0.days }
        let events: [Event] = days.flatMap { $0.events }
        let sortedEvents = events.sorted()
        let now = Date()

        // Find the most recent upcoming event that is not today
        if let nextEvent = sortedEvents.first(where: { isoDateFormatter.date(from: $0.from)! > now }) {
            if Calendar.current.isDate(now, inSameDayAs: isoDateFormatter.date(from: nextEvent.from)!) {
                // If the next event is today, find the next upcoming event that is not today
                if let nextNonTodayEvent = sortedEvents.first(where: {
                    let nextDate = isoDateFormatter.date(from: $0.from)!
                    let isSameDay = Calendar.current.isDate(now, inSameDayAs: nextDate)
                    return !isSameDay && nextDate > now
                }) {
                    return nextNonTodayEvent
                } else {
                    // If there are no more non-today events, return nil
                    return nil
                }
            } else {
                return nextEvent
            }
        }
        return nil
    }

    
    func filterEventsMatchingToday(events: [Event]) -> [Event] {
        let now = Date()
        let calendar = Calendar.current
        let currentDayOfYear = calendar.ordinality(of: .day, in: .year, for: now) ?? 1
        let filteredEvents = events.filter { event in
            guard let date = isoDateFormatter.date(from: event.from) else { return false }
            let dayOfYear = calendar.ordinality(of: .day, in: .year, for: date) ?? 1
            return dayOfYear == currentDayOfYear
        }
        return filteredEvents.sorted().reversed()
    }
    
    func createEventsForToday(schedules: [Schedule]) {
        let eventsForToday: [Event] = loadEventsForWeek(schedules: Array(schedules)).sorted().reversed()
        createDayCards(events: Array(eventsForToday))
    }
    
    func loadEventsForWeek(schedules: [Schedule]) -> [Event] {
        let now = Calendar.current.startOfDay(for: Date())
        let timeZone = TimeZone.current
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = timeZone
        let weekEndDate = calendar.date(byAdding: .day, value: 7, to: now)!
        let weekDateRange = now...weekEndDate
        AppLogger.shared.debug("Date range: \(weekDateRange)", source: "ScheduleService")
        let events = schedules
            .filter { $0.toggled }
            .flatMap { $0.days }
            .filter {
                if let eventDate = isoDateFormatterFract.date(from: $0.isoString) {
                    return weekDateRange.contains(eventDate)
                }
                return false
            }
            .flatMap { $0.events }
        return events
    }
}
