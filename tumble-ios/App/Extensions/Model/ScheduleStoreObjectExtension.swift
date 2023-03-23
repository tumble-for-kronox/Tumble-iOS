//
//  ScheduleStoreObjectExtension.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 2023-02-06.
//

import Foundation

extension [ScheduleStoreModel] {
    
    func removeDuplicateEvents() -> [ScheduleStoreModel] {
        var eventIds = Set<String>()
        return self.map { schedule in
            let uniqueDays = schedule.days.map { day in
                let uniqueEvents = day.events.filter { event in
                    eventIds.insert(event.id).inserted
                }
                return Response.Day(name: day.name, date: day.date, isoString: day.isoString, weekNumber: day.weekNumber, events: uniqueEvents)
            }
            return ScheduleStoreModel(id: schedule.id, cachedAt: schedule.cachedAt, days: uniqueDays, lastUpdated: schedule.lastUpdated)
        }
    }
    
    func flatten() -> [DayUiModel] {
        var days: [DayUiModel] = []
        self.forEach { schedule in
            let generatedDaysForSchedule = schedule.days.reduce(into: []) {
                if $1.isValidDay() {$0.append($1)}}.toUiModel()
            days = days.combine(generatedDays: generatedDaysForSchedule)
        }
        return days.toOrderedDayUiModels()
    }
    
}
