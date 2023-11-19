//
//  WeekView.swift
//  Tumble
//
//  Created by Adis Veletanlic on 2023-06-06.
//

import SwiftUI

struct BookmarkWeekView: View {
    let scheduleWeeks: [Int : [Day]]
    @State private var currentPage = 0
    
    var body: some View {
        ZStack(alignment: .bottom) {
            TabView(selection: $currentPage) {
                ForEach(weekStartDates.indices, id: \.self) { index in
                        WeekPage(
                            weekStart: weekStartDates[index],
                            weekDays: scheduleWeeks[weekStartDates[index].get(.weekOfYear)] ?? []
                        )
                        .tag(index)
                        .preference(key: CurrentPagePreferenceKey.self, value: index)
                    }
            }
            .tabViewStyle(.page(indexDisplayMode: .always))
            .onPreferenceChange(CurrentPagePreferenceKey.self) { value in
                currentPage = value
            }

            CustomPageControlView(numberOfPages: weekStartDates.count, currentPage: $currentPage)
                .frame(width: 100, height: 20)
                .padding(.bottom, 10)
        }
    }
}
