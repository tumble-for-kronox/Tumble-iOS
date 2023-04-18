//
//  DayResonseExtension.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 2023-04-17.
//

import Foundation

extension [Response.Day] {
    func ordered() -> [Response.Day] {
        return self.compactMap { $0 }.sorted(by: {
            // Ascending order
            isoDateFormatterFract.date(from: $0.isoString)! < isoDateFormatterFract.date(from: $1.isoString)!
        })
    }
}

extension Response.Day {
    func isValidDay() -> Bool {
        isoDateFormatterFract.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        let dayIsoString: String = self.isoString
        guard let day = isoDateFormatterFract.date(from: dayIsoString) else { return false }
        let today = Date()
        return Calendar.current.startOfDay(for: day) >= Calendar.current.startOfDay(for: today)
    }
}
