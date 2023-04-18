//
//  RealmScheduleExtension.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 2023-04-17.
//

import Foundation

extension [Schedule] {
    func flatten() -> [Day] {
        var days = [Day]()
            for schedule in self {
                days += schedule.days
            }
        return days
    }
}

extension Schedule {
    func courses() -> [String] {
        return Array(Set(self.days.flatMap { $0.events.compactMap { $0.course?.courseId } }))
    }
    
    func flatten() -> [Day] {
        return self.days.reduce(into: []) {
            if $1.isValidDay() {$0.append($1)}}
    }
    
}
