//
//  DayExtension.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 2023-02-02.
//

import Foundation

extension [Response.Day] {
    func toUiModel() -> [DayUiModel] {
        return self.map { day in
            return DayUiModel(name: day.name, date: day.date, isoString: day.isoString, weekNumber: day.weekNumber, events: day.events)
        }
    }

    // Used in ScheduleMainPageView when loading a schedule
    // from the local database and converting into a list of UI models
    func toOrderedDays() -> [DayUiModel] {
        isoDateFormatterFract.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
                var days: [DayUiModel] = []
                days.append(contentsOf: self.reduce(into: []) {
                    if $1.isValidDay() {$0.append($1)}}.toUiModel())
                return days.toOrderedDayUiModels()
    }

}

extension Response.Day {
    // This function uses the inDateFormatter property to parse the isoString property into a Date object. If the parsing fails, the function
    // returns false. Otherwise, it compares the day to the current date using the >= operator.
    // The startOfDay property of Date is used to ignore the time component of the date and only compare the day, month and year.
    func isValidDay() -> Bool {
        isoDateFormatterFract.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        let dayIsoString: String = self.isoString
        guard let day = isoDateFormatterFract.date(from: dayIsoString) else { return false }
        let today = Date()
        return Calendar.current.startOfDay(for: day) >= Calendar.current.startOfDay(for: today)
    }
}
