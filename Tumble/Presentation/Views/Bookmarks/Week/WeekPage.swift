//
//  WeekPage.swift
//  Tumble
//
//  Created by Adis Veletanlic on 11/19/23.
//

import SwiftUI

struct WeekPage: View {
    let weekStart: Date
    let weekDays: [Day]
    
    var body: some View {
        let weekOfYear = weekStart.get(.weekOfYear)

        ScrollView (showsIndicators: false) {
            VStack {
                HStack {
                    Spacer()
                    Text(String(format: NSLocalizedString("w. %@", comment: ""), "\(weekOfYear)"))
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundColor(.onBackground)
                }

                let daysForWeek = weekDays.normalizedToWeekDays()

                if weekDays.isEmpty {
                    VStack {
                        Text(NSLocalizedString("No events for this week..", comment: ""))
                            .foregroundColor(.onBackground)
                            .infoBodyMedium()
                        Image("GirlRelaxing")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 175)
                            .padding(.top, 15)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                    .padding(.top, 30)
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
