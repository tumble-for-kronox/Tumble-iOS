//
//  HomeViewModelExtension.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 2023-04-01.
//

import Foundation

extension HomeViewModel {
    
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
    
    
    func loadEventsForWeek() -> [Event] {
        let now = Calendar.current.startOfDay(for: Date())
        let timeZone = TimeZone.current
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = timeZone
        let weekEndDate = calendar.date(byAdding: .day, value: 7, to: now)!
        let weekDateRange = now...weekEndDate
        AppLogger.shared.debug("Date range: \(weekDateRange)", source: "ScheduleService")
        let hiddenBookmarks = bookmarks?.filter { !$0.toggled }.map { $0.id } ?? []
        let events = Array(schedules)
            .filter { !hiddenBookmarks.contains($0.scheduleId) }
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
