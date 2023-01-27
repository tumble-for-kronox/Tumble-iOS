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



extension [Response.Schedule] {
    
    func flatten() -> [DayUiModel] {
        var days: [DayUiModel] = []
        self.forEach { schedule in
            days.append(contentsOf: schedule.days.reduce(into: []) {
                if $1.isValidDay() {$0.append($1)}}.toUiModel())
        }
        return days.toOrderedDayUiModels()
    }
    
    func removeDuplicateEvents() -> [Response.Schedule] {
        var eventIds = Set<String>()
        return self.map { schedule in
            let uniqueDays = schedule.days.map { day in
                let uniqueEvents = day.events.filter { event in
                    eventIds.insert(event.id).inserted
                }
                return Response.Day(name: day.name, date: day.date, isoString: day.isoString, weekNumber: day.weekNumber, events: uniqueEvents)
            }
            return Response.Schedule(id: schedule.id, cachedAt: schedule.cachedAt, days: uniqueDays)
        }
    }


}

extension Response.Schedule {
    
    func assignCoursesRandomColors() -> [String : [String : Color]] {
        var courseColors: [String : [String : Color]] = [:]
        var availableColors = Set(colors)
        for day in self.days {
            for event in day.events {
                if courseColors[event.course.id] == nil {
                    if let hexColorString = availableColors.popFirst() {
                        courseColors[event.course.id] = [hexColorString : hexStringToUIColor(hex: hexColorString)]
                    }
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
    
    func isEmpty() -> Bool {
        return days.allSatisfy { $0.events.isEmpty }
    }


}

extension [DayUiModel] {
    private func merge() -> [DayUiModel] {
        var days: [DayUiModel: [Response.Event]] = [:]
        for day in self {
            if let events = days[day] {
                days[day] = events + day.events
            } else {
                days[day] = day.events
            }
        }
        return days.map { DayUiModel(name: $0.key.name, date: $0.key.date, isoString: $0.key.isoString, weekNumber: $0.key.weekNumber, events: $0.value) }
    }

    
    func toOrderedDayUiModels() -> [DayUiModel] {
        return self.compactMap { $0 }.merge().sorted(by: {
            // Ascending order
            inDateFormatter.date(from: $0.isoString)! < inDateFormatter.date(from: $1.isoString)!
        })
    }
}

extension DayUiModel {
    // Returns either day.name or "Today". The current date has to
    // correspond to the given days date in order for the function
    // to return "Today" as a string
    func string() -> String {
        inDateFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        let dayIsoString: String = self.isoString
        guard let day = inDateFormatter.date(from: dayIsoString) else { return "" }
        let today = Date()
        if Calendar.current.startOfDay(for: day) == Calendar.current.startOfDay(for: today) {
            return "Today"
        }
        return self.name
    }
}


extension [Response.Day] {
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

extension Response.Day {
    // This function uses the inDateFormatter property to parse the isoString property into a Date object. If the parsing fails, the function
    // returns false. Otherwise, it compares the day to the current date using the >= operator.
    // The startOfDay property of Date is used to ignore the time component of the date and only compare the day, month and year.
    func isValidDay() -> Bool {
        inDateFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        let dayIsoString: String = self.isoString
        guard let day = inDateFormatter.date(from: dayIsoString) else { return false }
        let today = Date()
        return Calendar.current.startOfDay(for: day) >= Calendar.current.startOfDay(for: today)
    }
}
