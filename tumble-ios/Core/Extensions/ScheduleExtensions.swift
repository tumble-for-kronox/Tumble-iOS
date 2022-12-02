//
//  ScheduleExtensions.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 11/18/22.
//

import Foundation
import SwiftUI

///To convert API result date (ISO8601) to `Date`, this property should not be inside any methods
let inDateFormatter = ISO8601DateFormatter()

extension [API.Types.Response.Schedule] {
    func flatten() -> [DayUiModel] {
        inDateFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        var days: [DayUiModel] = []
        self.forEach { schedule in
            days.append(contentsOf: schedule.days.reduce(into: []) { if inDateFormatter.date(from: $1.isoString)! >= Date() {$0.append($1)}}.toUiModel())
        }
        return days.compactMap { $0 }.merge().sorted(by: {inDateFormatter.date(from: $0.isoString)! < inDateFormatter.date(from: $1.isoString)!})
    }
}

extension API.Types.Response.Schedule {
    func assignCoursesColors() -> [String : Color] {
        var coursesColors: [String : Color] = [:]
        for day in self.days {
            for event in day.events {
                if coursesColors[event.course.id] == nil {
                    coursesColors[event.course.id] = hexStringToUIColor(hex: colors.randomElement()!)
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
}

extension [API.Types.Response.Day] {
    func toUiModel() -> [DayUiModel] {
        return self.map { day in
            return DayUiModel(name: day.name, date: day.date, isoString: day.isoString, weekNumber: day.weekNumber, events: day.events)
        }
    }
}

extension API.Types.Response.Event {
    func color() -> Color {
        var hexColor: String = ""
        CourseStore.load { result in
            switch result {
            case .failure(_):
                print("Error on course with id: \(self.id)")
            case .success(let courses):
                if !courses.isEmpty {
                    hexColor = courses.first(where: {$0.id == self.course.id})!.hexColor
                }
            }
        }
        return hexColor == "" ? hexStringToUIColor(hex: colors.randomElement() ?? "FFFFFF") : hexStringToUIColor(hex: hexColor)
    }
}
