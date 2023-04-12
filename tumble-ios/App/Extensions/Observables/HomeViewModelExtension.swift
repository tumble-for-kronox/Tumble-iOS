//
//  HomeViewModelExtension.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 2023-04-01.
//

import Foundation

extension HomeViewModel {
    
    func filterEventsMatchingToday(events: [Response.Event]) -> [Response.Event] {
        let now = Date()
        let calendar = Calendar.current
        let currentDayOfYear = calendar.ordinality(of: .day, in: .year, for: now) ?? 1
        let filteredEvents = events.filter { event in
            guard let date = isoDateFormatter.date(from: event.from) else { return false }
            let dayOfYear = calendar.ordinality(of: .day, in: .year, for: date) ?? 1
            return dayOfYear == currentDayOfYear
        }

        return filteredEvents
    }
    
    func findNextUpcomingEvent() {
        scheduleService.load(completion: { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let schedules):
                let hiddenBookmarks = self.preferenceService.getHiddenBookmarks()
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
                            self.nextClass = nextNonTodayEvent
                        } else {
                            self.nextClass = nil
                        }
                    } else {
                        // If the next event is not today, set it as the next class
                        self.nextClass = nextEvent
                    }
                } else {
                    self.nextClass = nil
                }

            case .failure(let failure):
                AppLogger.shared.critical("Could not load schedules: \(failure)", file: "HomeViewModelExtension")
                break
            }
        })
    }

    
    func loadCourseColors(completion: @escaping ([String : String]) -> Void) -> Void {
        self.courseColorService.load { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let courseColors):
                completion(courseColors)
            case .failure(let failure):
                self.todayEventsSectionStatus = .error
                AppLogger.shared.debug("Error occured loading colors -> \(failure.localizedDescription)")
            }
        }
    }
    
}
