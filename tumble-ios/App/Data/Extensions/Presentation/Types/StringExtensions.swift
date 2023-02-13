//
//  Strings.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 11/19/22.
//

import Foundation
import SwiftUI

extension String {
    
    func getDateComponents() -> DateComponents? {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        if let date = formatter.date(from: self) {
            let calendar = Calendar.current
            let components = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: date)
            return components
        }
        return nil
    }

    
    func abbreviate() -> String {
        let formatter = PersonNameComponentsFormatter()
        if let components = formatter.personNameComponents(from: self) {
             formatter.style = .abbreviated
             return formatter.string(from: components)
        }
        return ""
    }
    
    func toColor () -> Color {
        var cString:String = self.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()

        if (cString.hasPrefix("#")) {
            cString.remove(at: cString.startIndex)
        }

        if ((cString.count) != 6) {
            return Color.gray
        }

        var rgbValue:UInt64 = 0
        Scanner(string: cString).scanHexInt64(&rgbValue)

        return Color(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0
        )
    }
    
    // Should not be used with strings that are not ISO formatted
    func ISOtoHoursAndMinutes() -> String {
        
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
