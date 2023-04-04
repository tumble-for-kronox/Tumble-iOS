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
    
    func findNextUpcomingEvent(events: [Response.Event]) -> Response.Event? {
        let now = Date()
        let calendar = Calendar.current
        
        let sortedEvents = events.sorted { (event1, event2) -> Bool in
            guard let date1 = isoDateFormatter.date(from: event1.from),
                  let date2 = isoDateFormatter.date(from: event2.from) else {
                return false
            }
            return date1 < date2
        }
        
        for event in sortedEvents {
            guard let startDate = isoDateFormatter.date(from: event.from),
                  !calendar.isDate(startDate, inSameDayAs: now) else {
                continue
            }
            
            return event
        }
        
        return nil
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
