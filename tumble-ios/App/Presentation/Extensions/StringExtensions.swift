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
    
    // Checks if the given day name is todays day,
    // if so it returns the string 'Today' instead of
    // the given date day name
    func day() -> String {
        let date = Date()
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_us")
        formatter.dateFormat = "EEEE"
        let today = formatter.string(from: date).capitalizingFirstLetter()
        if today == self {
            return "Today"
        } else {
            return self
        }
    }
    
    func capitalizingFirstLetter() -> String {
          return prefix(1).uppercased() + self.lowercased().dropFirst()
        }

}
