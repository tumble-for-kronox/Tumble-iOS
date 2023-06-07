//
//  WeekView.swift
//  Tumble
//
//  Created by Adis Veletanlic on 2023-06-06.
//

import SwiftUI

struct BookmarkWeekView: View {
    
    let scheduleWeeks: [Int : [Day]]
    @State private var currentIndex = 0
        
    var body: some View {
        TabView(selection: $currentIndex) {
            ForEach(weekStartDates, id: \.self) { weekStart in
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
        ScrollView (showsIndicators: false) {
            HStack {
                Text(NSLocalizedString("w. \(weekStart.get(.weekOfYear))", comment: ""))
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundColor(.onBackground)
                Spacer()
            }

            let daysForWeek = weekDays.normalizedToWeekDays()

            if weekDays.isEmpty {
                Text("No days")
            } else {
                ForEach(1...7, id: \.self) { dayOfWeek in
                    let weekDayDate = gregorianCalendar.date(byAdding: .day, value: dayOfWeek - 1, to: weekStart)!
                    VStack {
                        WeekDays(days: daysForWeek[dayOfWeek], weekDayDate: weekDayDate)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            Spacer()
        }
        .frame(maxWidth: .infinity)
        .padding([.top, .horizontal], 15)
    }
}

struct WeekDays: View {
    
    let days: [Day]?
    let weekDayDate: Date
    
    var body: some View {
        Section(
            header: WeekDaySectionDivider(
                dateString: dateFormatterDayMonth.string(from: weekDayDate),
                dayName: dateFormatterDay.string(from: weekDayDate)
            ),
            content: {
            if let days = days {
                ForEach(days, id: \.self) { day in
                    ForEach(day.events, id: \.self) { event in
                        WeekEvent(event: event)
                    }
                }
            } else {
                HStack {
                    Text("No events this day")
                    Spacer()
                }
            }
        })
        .padding(.vertical, 10)
    }
}

struct WeekDaySectionDivider: View {
    let dateString: String
    let dayName: String
    
    var body: some View {
        HStack {
            Text("\(dayName) \(dateString)")
                .foregroundColor(.onBackground)
                .font(.system(size: 18, weight: .semibold))
            Rectangle()
                .fill(Color.onBackground)
                .offset(x: 7.5)
                .frame(height: 1)
                .cornerRadius(20)
            Spacer()
        }
    }
}

struct WeekEvent: View {
    
    let event: Event
    
    var body: some View {
        if let time = event.from.convertToHoursAndMinutesISOString(),
           let color = event.course?.color.toColor() {
            HStack {
                Circle()
                    .foregroundColor(event.isSpecial ? Color.red : color)
                    .frame(width: 7, height: 7)
                    .padding(.trailing, 0)
                Text(time)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.onSurface)
                Spacer()
                Text(event.title)
            }
            .padding()
            .frame(maxWidth: .infinity, maxHeight: 50)
            .background(Color.surface)
            .cornerRadius(10)
        }
    }
    
}
