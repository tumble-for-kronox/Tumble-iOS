//
//  ScheduleGrouperView.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 11/21/22.
//

import SwiftUI

struct ScheduleListView: View {
    let days: [DayUiModel]
    let courseColors: CourseAndColorDict
    var body: some View {
        ZStack {
            ScrollView {
                LazyVStack (spacing: 0) {
                    ForEach(days, id: \.id) { day in
                        if !(day.events.isEmpty) {
                            Section(header: DayHeaderSectionView(day: day), content: {
                                ForEach(day.events, id: \.id) { event in
                                    ScheduleCardView(event: event, isLast: event == day.events.last, color: hexStringToUIColor(hex: courseColors[event.course.id] ?? "FFFFFF"))
                                        .animation(.default)
                                }
                            })
                            .padding(.top, 35)
                        }
                    }
                    
                }
                .padding(7.5)
            }
        }
    }
}
