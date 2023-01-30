//
//  ScheduleGrouperView.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 11/21/22.
//

import SwiftUI

typealias OnTapCard = (Response.Event) -> Void

struct ScheduleListView: View {
    let days: [DayUiModel]
    let courseColors: CourseAndColorDict
    let onTapCard: OnTapCard
    @State private var sheetIsPresented: Bool = false
    var body: some View {
        ZStack {
            ScrollView {
                LazyVStack {
                    Rectangle().foregroundColor(.clear).frame(height: 1.0)
                    ForEach(days, id: \.id) { day in
                        if !(day.events.isEmpty) {
                            Section(header: DayHeaderSectionView(day: day), content: {
                                ForEach(day.events, id: \.id) { event in
                                    ScheduleCardView(onTapCard: onTapCard, event: event, isLast: event == day.events.last, color: hexStringToUIColor(hex: courseColors[event.course.id] ?? "FFFFFF"))
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
