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
                let day = Calendar.current.dateComponents([.day], from: inDateFormatter.date(from: $1.isoString)!).day!
                let today = Calendar.current.dateComponents([.day], from: Date.now).day!
                if day >= today {$0.append($1)}}.toUiModel())
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
    func assignRandomCoursesColors() -> [String : [String : Color]] {
        var coursesColors: [String : [String : Color]] = [:]
        for day in self.days {
            for event in day.events {
                if coursesColors[event.course.id] == nil {
                    let hexColorString = colors.randomElement()!;
                    coursesColors[event.course.id] = [hexColorString : hexStringToUIColor(hex: hexColorString)]
                }
            }
        }
        return coursesColors
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
    
    
    func toOrderedDays() -> [DayUiModel] {
        inDateFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        var days: [DayUiModel] = []
        days.append(contentsOf: self.reduce(into: []) {
            let day = Calendar.current.dateComponents([.day], from: inDateFormatter.date(from: $1.isoString)!).day!
            let today = Calendar.current.dateComponents([.day], from: Date.now).day!
            if day >= today {$0.append($1)}}.toUiModel())
        return days.toOrderedDayUiModels()
    }
}

extension API.Types.Response.Event {
    func color() -> Color {
        var hexColor: String = ""
        CourseColorStore.load { result in
            switch result {
            case .failure(_):
                print("Error on course with id: \(self.id)")
            case .success(let courses):
                if !courses.isEmpty {
                    print(course.id)
                    hexColor = courses[course.id]!
                }
            }
        }
        return hexColor == "" ? hexStringToUIColor(hex: colors.randomElement() ?? "FFFFFF") : hexStringToUIColor(hex: hexColor)
    }
}
