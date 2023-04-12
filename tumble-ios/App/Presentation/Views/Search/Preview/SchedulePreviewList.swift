//
//  SchedulePreviewGrouperListView.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 2022-12-02.
//

import SwiftUI
import Combine

enum ButtonState {
    case loading
    case saved
    case notSaved
}

struct SchedulePreviewList: View {
            
    @ObservedObject var parentViewModel: SearchViewModel
    let courseColors: [String : String]
    let days: [DayUiModel]
    
    init(
        parentViewModel: SearchViewModel,
        courseColors: [String : String],
        days: [DayUiModel]) {
            
        self.parentViewModel = parentViewModel
        self.courseColors = courseColors
        self.days = days
    }
    
    var body: some View {
        ZStack {
            ScrollView (showsIndicators: false) {
                LazyVStack (spacing: 0) {
                    ForEach(days, id: \.id) { day in
                        if !(day.events.isEmpty) {
                            VStack {
                                Section(header: DayHeader(day: day), content: {
                                    ForEach(day.events, id: \.id) { event in
                                        VerboseEventButtonLabel(
                                            event: event,
                                            color: courseColors[event.course.id]!.toColor()
                                        )
                                    }
                                })
                            }
                            .padding(.bottom, 35)
                        }
                    }
                }
                .padding(.horizontal, 7.5)
            }
        }
    }
}
