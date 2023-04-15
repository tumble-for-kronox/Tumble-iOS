//
//  ScheduleExtensions.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 11/18/22.
//

import Foundation
import SwiftUI


extension [Response.Schedule] {
    
    func flatten() -> [DayUiModel] {
        var days: [DayUiModel] = []
        self.forEach { schedule in
            let generatedDaysForSchedule = schedule.days.reduce(into: []) {
                if $1.isValidDay() {$0.append($1)}}.toUiModel()
            days = days.combine(generatedDays: generatedDaysForSchedule)
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
                return Response.Day(
                    name: day.name,
                    date: day.date,
                    isoString: day.isoString,
                    weekNumber: day.weekNumber,
                    events: uniqueEvents
                )
            }
            return Response.Schedule(id: schedule.id, cachedAt: schedule.cachedAt, days: uniqueDays)
        }
    }
}

extension Response.Schedule {
    
    // Returns dictionary of random colors for each course in a schedule
    func assignCoursesRandomColors() -> [String : String] {
        var courseColors: [String : String] = [:]
        var availableColors = Set(colors)
        for day in self.days {
            for event in day.events {
                if courseColors[event.course.id] == nil {
                    if let hexColorString = availableColors.popFirst() {
                        courseColors[event.course.id] = hexColorString
                    }
                }
            }
        }
        return courseColors
    }
    
    func flatten() -> [DayUiModel] {
        return self.days.reduce(into: []) {
            if $1.isValidDay() {$0.append($1)}}.toUiModel()
    }

    
    func courses() -> [String] {
        return Array(Set(self.days.flatMap { $0.events.map { $0.course.id } }))
    }
    
    func isEmpty() -> Bool {
        return days.allSatisfy { $0.events.isEmpty }
    }


}
