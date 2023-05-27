//
//  RealmScheduleExtension.swift
//  Tumble
//
//  Created by Adis Veletanlic on 2023-04-17.
//

import Foundation

extension [Schedule] {
    
    /// Creates a list of days with subsequent
    /// events for those days, merging multiple schedules
    func flattenAndMerge() -> [Day] {
        var days = [Day]()
        for schedule in self {
            days += schedule.days
        }
        
        var dayDictionary: [String : Day] = [:]
        for day in days {
            if let existingDay = dayDictionary[day.isoString] {
                existingDay.events.append(objectsIn: day.events)
                dayDictionary[day.isoString] = existingDay
            } else {
                let newDay = Day()
                newDay.name = day.name
                newDay.date = day.date
                newDay.isoString = day.isoString
                newDay.weekNumber = day.weekNumber
                newDay.events.append(objectsIn: day.events)
                dayDictionary[day.isoString] = newDay
            }
        }
        return Array<Day>(dayDictionary.values)
    }
}

extension Schedule {
    
    func courses() -> [String] {
        return Array(Set(days.flatMap { $0.events.compactMap { $0.course?.courseId } }))
    }
    
    func flatten() -> [Day] {
        return days.reduce(into: []) {
            if $1.isValidDay() { $0.append($1) }
        }
    }
    
    func isMissingEvents() -> Bool {
        for day in days {
            for event in day.events {
                if !event.title.isEmpty {
                    return false
                }
            }
        }
        return true
    }
}
