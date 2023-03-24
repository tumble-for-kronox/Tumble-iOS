//
//  Utilities.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 2023-01-31.
//

import Foundation
import UIKit

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
    let currentDate = Date()
    if truncate {
        dateFormatterLong.dateStyle = .medium
    }
    dateFormatterLong.timeStyle = .none
    let dateString = dateFormatterLong.string(from: currentDate)
    return dateString
}


/// Formatters used globally

/// To convert API result date (ISO8601) to `Date`
let isoDateFormatterFract: ISO8601DateFormatter = {
    let formatter = ISO8601DateFormatter()
    formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
    return formatter
}()

/// Used on event dates
let dateFormatterEvent: DateFormatter = {
    let eventDateFormatter = DateFormatter()
    eventDateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
    return eventDateFormatter
}()

let dateFormatterComma: DateFormatter = {
    let formatter = DateFormatter()
    formatter.locale = Locale(identifier: "en_US_POSIX")
    formatter.dateFormat = "EEEE, MMMM d, yyyy"
    return formatter
}()

let dateFormatterFull: DateFormatter = {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
    return dateFormatter
}()

let dateFormatterSemi: DateFormatter = {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd"
    return dateFormatter
}()

let isoDateFormatterDashed: ISO8601DateFormatter = {
    let formatter = ISO8601DateFormatter()
    formatter.formatOptions = [.withFullDate, .withDashSeparatorInDate]
    return formatter
}()

let isoDateFormatter: ISO8601DateFormatter = ISO8601DateFormatter()

let dateFormatterLong: DateFormatter = {
    let dateFormatter = DateFormatter()
    dateFormatter.locale = Locale(identifier: "en_US")
    dateFormatter.dateStyle = .long
    return dateFormatter
}()
