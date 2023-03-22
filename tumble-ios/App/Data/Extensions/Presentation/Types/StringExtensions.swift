//
//  Strings.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 11/19/22.
//

import Foundation
import SwiftUI

let extensionDateFormatter = DateFormatter()
let extensionIsoFormatter = ISO8601DateFormatter()

extension String {
    
    func getDateComponents() -> DateComponents? {
        extensionDateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        extensionDateFormatter.locale = Locale(identifier: "en_US_POSIX")
        if let date = extensionDateFormatter.date(from: self) {
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
    
    func formatDate() -> String? {
        extensionIsoFormatter.formatOptions = [.withFullDate, .withDashSeparatorInDate]
        if let date = extensionIsoFormatter.date(from: self) {
            extensionDateFormatter.dateFormat = "yyyy-MM-dd"
            extensionDateFormatter.timeZone = TimeZone(abbreviation: "UTC")
            return extensionDateFormatter.string(from: date)
        }
        
        return nil
    }

    
    /// Should not be used with strings that are not ISO formatted
    func convertToHoursAndMinutesISOString() -> String? {
        guard let date = extensionIsoFormatter.date(from: self) else {
            return nil
        }
        
        let calendar = Calendar.current
        let components = calendar.dateComponents([.hour, .minute], from: date)
        
        guard let hour = components.hour, let minute = components.minute else {
            return nil
        }
        
        return String(format: "%02d:%02d", hour, minute)
    }
    
    func convertToHoursAndMinutes() -> String? {
        extensionDateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        guard let date = extensionDateFormatter.date(from: self) else {
            return nil
        }
        
        let calendar = Calendar.current
        let components = calendar.dateComponents([.hour, .minute], from: date)
        
        guard let hour = components.hour, let minute = components.minute else {
            return nil
        }
        
        return String(format: "%02d:%02d", hour, minute)
    }
    
    func isValidSignupDate() -> Bool {
        extensionDateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        guard let date = extensionDateFormatter.date(from: self) else {
            return false
        }
        return date > Date()
    }
    
    func toDate() -> String? {
        extensionDateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        if let date = extensionDateFormatter.date(from: self) {
            extensionDateFormatter.dateFormat = "yyyy-MM-dd"
            return extensionDateFormatter.string(from: date)
        }
        return nil
    }
    
    func isAvailableNotificationDate() -> Bool {
        guard let eventDate = extensionIsoFormatter.date(from: self) else {
            return false
        }

        let now = Date()
        let threeHoursFromNow = Calendar.current.date(byAdding: .hour, value: 3, to: now)!

        return eventDate > now && eventDate > threeHoursFromNow
    }



    
    // Checks if the given day name is todays day,
    // if so it returns the string 'Today' instead of
    // the given date day name
    func day() -> String {
        let date = Date()
        extensionDateFormatter.locale = Locale(identifier: "en_us")
        extensionDateFormatter.dateFormat = "EEEE"
        let today = extensionDateFormatter.string(from: date).capitalizingFirstLetter()
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
