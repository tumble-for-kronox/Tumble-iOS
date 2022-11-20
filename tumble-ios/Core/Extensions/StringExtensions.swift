//
//  Strings.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 11/19/22.
//

import Foundation

extension String {
    
    // Should not be used with strings that are not ISO formatted
    func ISOtoHours() -> String {
        let date: Date? = ISO8601DateFormatter().date(from: self)
        let calendar = Calendar.current
        var hour: String = String(calendar.component(.hour, from: date!))
        var minutes = String(calendar.component(.minute, from: date!))
        if (hour.last == "0" && hour.count < 2) {
            hour = hour + "0"
        }
        if (minutes.last == "0" && minutes.count < 2) {
            minutes = minutes + "0"
        }
        return String("\(hour):\(minutes)")
    }
}
