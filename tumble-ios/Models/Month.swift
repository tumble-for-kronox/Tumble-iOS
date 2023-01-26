//
//  Month.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 2023-01-26.
//

import Foundation

struct Month {
    var monthType: MonthType
    var day: Int
    func dayOfWeek() -> String {
        return String(day)
    }
}


enum MonthType {
    case previous
    case current
    case next
}
