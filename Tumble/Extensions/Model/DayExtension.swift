//
//  DayExtension.swift
//  Tumble
//
//  Created by Adis Veletanlic on 2023-02-02.
//

import Foundation

extension [Day] {
    
    /// Orderes the days in ascending order
    /// comparing the 'isoString' attribute
    func ordered() -> [Day] {
        compactMap { $0 }.sorted(by: {
            if let fromFirst = isoDateFormatterFract.date(from: $0.isoString), let fromSecond = isoDateFormatterFract.date(from: $1.isoString) {
                return fromFirst < fromSecond
            }
            return false
        })
    }
    
    /// Retrieves list of days where
    /// events are not empty
    func filterEmptyDays() -> [Day] {
        self.filter { !$0.events.isEmpty }
    }
    
    func filterValidDays() -> [Day] {
        self.filter { $0.isValidDay() }
    }
    
    func groupedByWeeks() -> [Int : [Day]] {
        var weeks: [Int : [Day]] = [:]
        for day in self {
            if let date = isoDateFormatterFract.date(from: day.isoString) {
                let weekOfYear: Int = Calendar.current.component(.weekOfYear, from: date)
                weeks[weekOfYear, default: []].append(day)
            }
        }
        return weeks
    }

}

extension Day {
    // This function uses the isoDateFormatterFract property to parse the isoString property into a Date object. If the parsing fails, the function
    // returns false. Otherwise, it compares the day to the current date using the >= operator.
    // The startOfDay property of Date is used to ignore the time component of the date and only compare the day, month and year.
    func isValidDay() -> Bool {
        isoDateFormatterFract.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        let dayIsoString: String = isoString
        guard let day = isoDateFormatterFract.date(from: dayIsoString) else { return false }
        let today = Date()
        return Calendar.current.startOfDay(for: day) >= Calendar.current.startOfDay(for: today)
    }
    
    var dayOfWeek: Int? {
        guard let date = isoDateFormatterFract.date(from: self.isoString) else {
            return nil
        }
        
        let weekday = Calendar.current.component(.weekday, from: date)
        let offset = (weekday - Calendar.current.firstWeekday + 7) % 7
        return offset
    }
}
