//
//  StringExtensions.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 11/19/22.
//

import Foundation
import SwiftUI

extension String {
        
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
        if let date = isoDateFormatterDashed.date(from: self) {
            dateFormatterSemi.timeZone = TimeZone(abbreviation: "UTC")
            return dateFormatterSemi.string(from: date)
        }
        return nil
    }

    
    // Should not be used with strings that are not ISO formatted
    func convertToHoursAndMinutesISOString() -> String? {
        guard let date = isoDateFormatter.date(from: self) else {
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
        guard let date = dateFormatterFull.date(from: self) else {
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
        guard let date = dateFormatterFull.date(from: self) else {
            return false
        }
        return date > Date()
    }
    
    func toDate() -> String? {
            if let date = dateFormatterFull.date(from: self) {
                return dateFormatterSemi.string(from: date)
            }
            return nil
        }
    
    func isAvailableNotificationDate() -> Bool {
        guard let eventDate = isoDateFormatter.date(from: self) else {
            return false
        }
        let now = Date()
        let threeHoursFromNow = Calendar.current.date(byAdding: .hour, value: 3, to: now)!
        return eventDate > now && eventDate > threeHoursFromNow
    }
    
    func capitalizingFirstLetter() -> String {
          return prefix(1).uppercased() + self.lowercased().dropFirst()
        }
    
}

