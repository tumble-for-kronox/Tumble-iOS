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
                    ForEach(days, id: \.self) { day in
                        ForEach(day.events.sorted(by: sortedOrder), id: \.self) { event in
                            WeekEvent(event: event)
                        }
                    }
                } else {
                    EmptyEvent()
                }
            }
        )
        .padding(.vertical, 10)
    }
    
    fileprivate func sortedOrder(event1: Event, event2: Event) -> Bool {
        guard let firstDate = Calendar.current.date(from: event1.dateComponents!),
             let secondDate = Calendar.current.date(from: event2.dateComponents!) else {
           return false
       }
       return firstDate < secondDate
    }
}
