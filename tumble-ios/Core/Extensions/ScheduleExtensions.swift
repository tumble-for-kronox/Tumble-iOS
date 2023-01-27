//
//  ScheduleExtensions.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 11/18/22.
//

import Foundation
import SwiftUI

//To convert API result date (ISO8601) to `Date`, this property should not be inside any methods
let inDateFormatter = ISO8601DateFormatter()



extension [API.Types.Response.Schedule] {
    
    func flatten() -> [DayUiModel] {
        inDateFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        var days: [DayUiModel] = []
        self.forEach { schedule in
            days.append(contentsOf: schedule.days.reduce(into: []) {
                if $1.isValidDay() {$0.append($1)}}.toUiModel())
        }
        return days.toOrderedDayUiModels()
    }
    
    func removeDuplicateEvents() -> [API.Types.Response.Schedule] {
        var uniqueSchedules = [API.Types.Response.Schedule]()
        var eventIds = Set<String>()
        for schedule in self {
            var uniqueDays = [API.Types.Response.Day]()
            for day in schedule.days {
                var uniqueEvents = [API.Types.Response.Event]()
                for event in day.events {
                    if eventIds.insert(event.id).inserted {
                        uniqueEvents.append(event)
                    }
                }
                let uniqueDay = API.Types.Response.Day(name: day.name, date: day.date, isoString: day.isoString, weekNumber: day.weekNumber, events: uniqueEvents)
                uniqueDays.append(uniqueDay)
            }
            let uniqueSchedule = API.Types.Response.Schedule(id: schedule.id, cachedAt: schedule.cachedAt, days: uniqueDays)
            uniqueSchedules.append(uniqueSchedule)
        }
        return uniqueSchedules
    }

}

extension API.Types.Response.Schedule {
    
    func assignCoursesRandomColors() -> [String : [String : Color]] {
        var courseColors: [String : [String : Color]] = [:]
        for day in self.days {
            for event in day.events {
                if courseColors[event.course.id] == nil {
                    let hexColorString = colors.randomElement()!;
                    courseColors[event.course.id] = [hexColorString : hexStringToUIColor(hex: hexColorString)]
                }
            }
        }
        return courseColors
    }
    
    func courses() -> [String] {
        var courses: [String] = []
        for day in self.days {
            for event in day.events {
                if !courses.contains(event.course.id) {
                    courses.append(event.course.id)
                }
            }
        }
        return courses
    }
}

extension [DayUiModel] {
    private func merge() -> [DayUiModel] {
        var days: [DayUiModel] = []
        for day in self {
            if days.contains(where: {$0.date == day.date}) {
                var events: [API.Types.Response.Event] = days.first(where: {$0.date == day.date})!.events
                events.append(contentsOf: day.events)
                let cloneDay = days.first(where: {$0.date == day.date})!
                days.removeAll(where: {$0.date == day.date})
                days.append(DayUiModel(name: cloneDay.name, date: cloneDay.date, isoString: cloneDay.isoString, weekNumber: cloneDay.weekNumber, events: events))
            } else {
                days.append(day)
            }
        }
        return days
    }
    
    func toOrderedDayUiModels() -> [DayUiModel] {
        return self.compactMap { $0 }.merge().sorted(by: {
            // Ascending order
            inDateFormatter.date(from: $0.isoString)! < inDateFormatter.date(from: $1.isoString)!
        })
    }
}


extension [API.Types.Response.Day] {
    func toUiModel() -> [DayUiModel] {
        return self.map { day in
            return DayUiModel(name: day.name, date: day.date, isoString: day.isoString, weekNumber: day.weekNumber, events: day.events)
        }
    }

    // Used in ScheduleMainPageView when loading a schedule
    // from the local database and converting into a list of UI models
    func toOrderedDays() -> [DayUiModel] {
        inDateFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        var days: [DayUiModel] = []
        days.append(contentsOf: self.reduce(into: []) {
            if $1.isValidDay() {$0.append($1)}}.toUiModel())
        return days.toOrderedDayUiModels()
    }
}

extension API.Types.Response.Day {
    // Determines if a schedule should be shown in the UI view based
    // on whether or not the day of the month has already passed or not
    func isValidDay() -> Bool {
        let dayIsoString: String = self.isoString
        let day: Int = Calendar.current.dateComponents([.day], from: inDateFormatter.date(from: dayIsoString)!).day!
        let today: Int = Calendar.current.dateComponents([.day], from: inDateFormatter.date(from: dayIsoString)!).day!
        let month: Int = Calendar.current.dateComponents([.month], from: Date.now).month!
        let todaysMonth: Int = Calendar.current.dateComponents([.month], from: Date.now).month!
        return ((day >= today && month == todaysMonth) || (month != todaysMonth))
    }
}
