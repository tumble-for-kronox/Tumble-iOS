//
//  WeekView.swift
//  Tumble
//
//  Created by Adis Veletanlic on 2023-06-06.
//

import SwiftUI

struct BookmarkWeekView: View {
    
    let scheduleWeeks: [Int : [Day]]
    
    let currentDate = Date()
    let calendar = Calendar.current

    var weeks: [Date] {
        var result: [Date] = []
        let startDate = currentDate

        // Find the nearest past Monday
        let currentWeekday = calendar.component(.weekday, from: startDate)
        let daysToSubtract = (currentWeekday + 5) % 7
        let nearestMonday = calendar.date(byAdding: .day, value: -daysToSubtract, to: startDate)!

        var currentDate = nearestMonday
        let endDate = calendar.date(byAdding: .month, value: 6, to: nearestMonday)!

        while currentDate <= endDate {
            result.append(currentDate)
            currentDate = calendar.date(byAdding: .weekOfYear, value: 1, to: currentDate)!
        }

        return result
    }


    @State private var currentIndex = 0
        
    var body: some View {
        TabView(selection: $currentIndex) {
            ForEach(weeks, id: \.self) { weekStart in
                WeekPage(
                    weekStart: weekStart,
                    weekDays: scheduleWeeks[weekStart.get(.weekOfYear)] ?? []
                )
                .tag(weekStart)
            }
        }
        .tabViewStyle(.page(indexDisplayMode: .never))
    }
}

struct WeekPage: View {
    
    let weekStart: Date
    let weekDays: [Day]
    
    var body: some View {
        VStack (alignment: .leading) {
            Text(NSLocalizedString("w. \(weekStart.get(.weekOfYear))", comment: ""))
                .font(.system(size: 22, weight: .semibold))
                .foregroundColor(.onBackground)

            var daysForWeek = Dictionary(grouping: weekDays) { day -> Int in
                let isoString = day.isoString
                let date = isoDateFormatterFract.date(from: day.isoString)! // Converts isoString to Date
                let weekday = Calendar.current.component(.weekday, from: date) // Fetches weekday from Date
                return weekday
            }

            if weekDays.isEmpty {
                Text("No days")
            } else {
                ForEach(1...7, id: \.self) { dayOfWeek in
                    VStack {
                        WeekDays(days: daysForWeek[dayOfWeek])
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            Spacer()
        }
        .frame(maxWidth: .infinity)
    }
}

struct WeekDays: View {
    
    let days: [Day]?
    
    var body: some View {
        if let days = days {
            ForEach(days, id: \.self) { day in
                Section(day.date) {
                    ForEach(day.events, id: \.self) { event in
                        WeekEvent(event: event)
                    }
                }
            }
        } else {
            Text("No events this day")
        }
    }
}

struct WeekEvent: View {
    
    let event: Event
    
    var body: some View {
        HStack {
            Text(event.title)
        }
    }
    
}
