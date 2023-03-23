//
//  Utilities.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 2023-01-31.
//

import Foundation
import UIKit

/// This is

func navigationBarFont() -> UIFont {
    var titleFont = UIFont.preferredFont(forTextStyle: .headline) 
            titleFont = UIFont(
                descriptor:
                    titleFont.fontDescriptor
                    .withSymbolicTraits(.traitBold)
                    ??
                    titleFont.fontDescriptor,
                size: titleFont.pointSize
            )
    return titleFont
}


func getCurrentDate(truncate: Bool = false) -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.locale = Locale(identifier: "en_US")
    let currentDate = Date()
    dateFormatter.dateStyle = .long
    if truncate {
        dateFormatter.dateStyle = .medium
    }
    dateFormatter.timeStyle = .none
    let dateString = dateFormatter.string(from: currentDate)
    return dateString
}


/// Formatters used globally
///

/// To convert API result date (ISO8601) to `Date`
let inDateFormatter: ISO8601DateFormatter = {
    let formatter = ISO8601DateFormatter()
    formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
    return formatter
}()

/// Used on event dates
let eventDateFormatter: DateFormatter = {
    let eventDateFormatter = DateFormatter()
    eventDateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
    return eventDateFormatter
}()

extension DateFormatter {
    static let shared: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        return formatter
    }()
}

extension ISO8601DateFormatter {
    static let shared: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withFullDate, .withDashSeparatorInDate]
        return formatter
    }()
}
