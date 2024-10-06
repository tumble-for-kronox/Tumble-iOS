//
//  WeekDays.swift
//  Tumble
//
//  Created by Adis Veletanlic on 11/19/23.
//

import SwiftUI

struct WeekDays: View {
    let days: [Day]?
    let weekDayDate: Date
    
    var body: some View {
        Section(
            header: HStack {
                Text("\(dateFormatterDay.string(from: weekDayDate)) \(dateFormatterDayMonth.string(from: weekDayDate))".capitalized)
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
                    VStack(spacing: Spacing.medium) {
                        ForEach(days, id: \.self) { day in
                            ForEach(day.events.sorted(by: EventSorting.sortedEventOrder), id: \.self) { event in
                                WeekEvent(event: event)
                            }
                        }
                    }
                } else {
                    EmptyEvent()
                }
            }
        )
        .padding(.vertical, Spacing.small)
    }
}
