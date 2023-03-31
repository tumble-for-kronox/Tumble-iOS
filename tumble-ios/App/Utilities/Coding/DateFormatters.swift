//
//  DateFormatters.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 2023-04-01.
//

import Foundation

/// Formatters used globally

/// To convert API result date (ISO8601) to `Date`
var isoDateFormatterFract: ISO8601DateFormatter = {
    let formatter = ISO8601DateFormatter()
    formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
    return formatter
}()

/// Used on event dates
var dateFormatterEvent: DateFormatter = {
    let eventDateFormatter = DateFormatter()
    eventDateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
    return eventDateFormatter
}()

var dateFormatterComma: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "EEEE, MMMM d, yyyy"
    return formatter
}()

var dateFormatterFull: DateFormatter = {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
    return dateFormatter
}()

var dateFormatterSemi: DateFormatter = {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd"
    return dateFormatter
}()

var isoDateFormatterDashed: ISO8601DateFormatter = {
    let formatter = ISO8601DateFormatter()
    formatter.formatOptions = [.withFullDate, .withDashSeparatorInDate]
    return formatter
}()

var isoDateFormatter: ISO8601DateFormatter = ISO8601DateFormatter()

var isoDateFormatterSemi: ISO8601DateFormatter = {
    let formatter = ISO8601DateFormatter()
    formatter.formatOptions = [.withFullDate, .withTimeZone]
    return formatter
}()

var dateFormatterLong: DateFormatter = {
    let dateFormatter = DateFormatter()
    dateFormatter.dateStyle = .long
    return dateFormatter
}()
