//
//  WeekView.swift
//  Tumble
//
//  Created by Adis Veletanlic on 2023-06-06.
//

import SwiftUI

struct BookmarkWeekView: View {
    let scheduleWeeks: [Int : [Day]]
        
    var body: some View {
        TabView {
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

private struct WeekPage: View {
    let weekStart: Date
    let weekDays: [Day]
    
    var body: some View {
        let weekOfYear = weekStart.get(.weekOfYear)

        ScrollView (showsIndicators: false) {
            VStack {
                HStack {
                    Spacer()
                    Text(NSLocalizedString("w. \(weekOfYear)", comment: ""))
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundColor(.onBackground)
                }

                let daysForWeek = weekDays.normalizedToWeekDays()

                if weekDays.isEmpty {
                    Text("No days")
                } else {
                    ForEach(1...7, id: \.self) { dayOfWeek in
                        let weekDayDate = gregorianCalendar.date(byAdding: .day, value: dayOfWeek - 1, to: weekStart)!
                        WeekDays(days: daysForWeek[dayOfWeek], weekDayDate: weekDayDate)
                            .frame(maxWidth: .infinity)
                    }
                }
                Spacer()
            }
            .frame(maxWidth: .infinity)
            .padding([.top, .horizontal], 15)
        }
    }
}

private struct WeekDays: View {
    let days: [Day]?
    let weekDayDate: Date
    
    var body: some View {
        Section(
            header: HStack {
                Text("\(dateFormatterDay.string(from: weekDayDate)) \(dateFormatterDayMonth.string(from: weekDayDate))")
                    .foregroundColor(.onBackground)
                    .font(.system(size: 18, weight: .semibold))
                Rectangle()
                    .fill(Color.onBackground)
                    .offset(x: 7.5)
                    .frame(height: 1)
                    .cornerRadius(20)
                Spacer()
            },
            content: {
                if let days = days {
                    ForEach(days, id: \.self) { day in
                        ForEach(day.events, id: \.self) { event in
                            WeekEvent(event: event)
                        }
                    }
                } else {
                    EmptyEventView()
                }
            }
        )
        .padding(.vertical, 10)
    }
}

private struct WeekEvent: View {
    let event: Event
    
    var body: some View {
        if let from = event.from.convertToHoursAndMinutesISOString(),
           let to = event.to.convertToHoursAndMinutesISOString(),
           let color = event.course?.color.toColor() {
            Button(action: {
                onTapCard(event: event)
            }, label: {
                HStack (alignment: .center) {
                    Circle()
                        .foregroundColor(event.isSpecial ? Color.red : color)
                        .frame(width: 7, height: 7)
                        .padding(.trailing, 0)
                    Text("\(from) - \(to)")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.onSurface)
                    Spacer()
                    Text(event.title)
                        .font(.system(size: 16, weight: .regular))
                        .foregroundColor(.onSurface)
                }
                .padding()
                .frame(maxWidth: .infinity, maxHeight: 50)
                .background(Color.surface)
                .cornerRadius(10)
            })
            .buttonStyle(AnimatedButtonStyle(color: .surface, applyCornerRadius: true))
        }
    }
    
    fileprivate func onTapCard(event: Event) {
        HapticsController.triggerHapticLight()
        AppController.shared.eventSheet = EventDetailsSheetModel(event: event)
    }
}

private struct EmptyEventView: View {
    var body: some View {
        HStack {
            Circle()
                .foregroundColor(.onSurface)
                .frame(width: 7, height: 7)
                .padding(.trailing, 0)
            Text(NSLocalizedString("No events this day", comment: ""))
            Spacer()
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: 50)
        .background(Color.surface)
        .cornerRadius(10)
    }
}


