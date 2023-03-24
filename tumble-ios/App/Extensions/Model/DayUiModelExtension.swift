//
//  DayUiModelExtension.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 2023-02-02.
//

import Foundation

extension [DayUiModel] {
    private func merge() -> [DayUiModel] {
        var days: [DayUiModel: [Response.Event]] = [:]
        for day in self {
            if let events = days[day] {
                days[day] = events + day.events
            } else {
                days[day] = day.events
            }
        }
        return days.map { DayUiModel(name: $0.key.name, date: $0.key.date, isoString: $0.key.isoString, weekNumber: $0.key.weekNumber, events: $0.value) }
    }

    
    func toOrderedDayUiModels() -> [DayUiModel] {
        return self.compactMap { $0 }.merge().sorted(by: {
            // Ascending order
            isoDateFormatterFract.date(from: $0.isoString)! < isoDateFormatterFract.date(from: $1.isoString)!
        })
    }
    
    func combine(generatedDays: [DayUiModel]) -> [DayUiModel] {
        var combinedDict = [String: DayUiModel]()
        
        for model in self + generatedDays {
            if combinedDict[model.isoString] == nil {
                combinedDict[model.isoString] = model
            } else {
                combinedDict[model.isoString]!.events.append(contentsOf: model.events)
            }
        }
        
        return Array(combinedDict.values)
    }
}

extension DayUiModel {
    // Returns either day.name or "Today". The current date has to
    // correspond to the given days date in order for the function
    // to return "Today" as a string
    func string() -> String {
        isoDateFormatterFract.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        let dayIsoString: String = self.isoString
        guard let day = isoDateFormatterFract.date(from: dayIsoString) else { return "" }
        let today = Date()
        if Calendar.current.startOfDay(for: day) == Calendar.current.startOfDay(for: today) {
            return "Today"
        }
        return self.name
    }
}
