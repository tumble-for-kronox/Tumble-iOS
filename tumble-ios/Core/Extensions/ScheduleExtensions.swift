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
    func toEvents() -> [API.Types.Response.Event] {
        return self.map { day in
            return day.events
        }.reduce([], +)
    }
}
