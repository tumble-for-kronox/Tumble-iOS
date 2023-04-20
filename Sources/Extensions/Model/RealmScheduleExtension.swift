//
//  RealmScheduleExtension.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 2023-04-17.
//

import Foundation

extension [Schedule] {
    func flattenAndMerge() -> [Day] {
        var days = [Day]()
        for schedule in self {
            days += schedule.days
        }
        let uniqueDays = Set(days.map { $0.date })
        var mergedDays = [Day]()

        for date in uniqueDays {
            let daysWithSameDate = days.filter { $0.date == date }
            let day = Day()
            day.name = daysWithSameDate.first?.name ?? ""
            day.date = date
            day.isoString = daysWithSameDate.first?.isoString ?? ""
            day.weekNumber = daysWithSameDate.first?.weekNumber ?? 0
            day.events.append(objectsIn: daysWithSameDate.flatMap { $0.events })
            mergedDays.append(day)
        }
        return mergedDays
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
}
