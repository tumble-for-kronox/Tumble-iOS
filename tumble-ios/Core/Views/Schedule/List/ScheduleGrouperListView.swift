//
//  ScheduleGrouperView.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 11/21/22.
//

import SwiftUI

struct ScheduleGrouperListView: View {
    let days: [DayUiModel]
    var body: some View {
        ScrollView {
            LazyVStack {
                ForEach(days, id: \.id) { day in
                    if !(day.events.isEmpty) {
                        Section(header: DayHeaderSectionView(day: day), content: {
                            ForEach(day.events, id: \.id) { event in
                                ScheduleCardView(event: event)
                            }
                        })
                        .padding(.top, 35)
                    }
                }
            }
        }
        .padding(.top, 20)
    }
}
