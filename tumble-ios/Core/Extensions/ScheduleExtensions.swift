//
//  ScheduleExtensions.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 11/18/22.
//

import Foundation

extension API.Types.Response.Schedule {
    
}

extension [API.Types.Response.Day] {
    func toUiModel() -> [DayUiModel] {
        return self.map { day in
            return DayUiModel(name: day.name, date: day.date, isoString: day.isoString, weekNumber: day.weekNumber, events: day.events)
        }
    }
}
