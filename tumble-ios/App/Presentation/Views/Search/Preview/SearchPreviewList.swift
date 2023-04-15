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

struct SearchPreviewList: View {
            
    @ObservedObject var viewModel: SearchPreviewViewModel
    
    var body: some View {
        ZStack {
            ScrollView (showsIndicators: false) {
                LazyVStack (spacing: 0) {
                    if let days = createDays() {
                        ForEach(days, id: \.id) { day in
                            if !(day.events.isEmpty) {
                                VStack {
                                    Section(header: DayHeader(day: day), content: {
                                        ForEach(day.events, id: \.id) { event in
                                            VerboseEventButtonLabel(
                                                event: event,
                                                color: viewModel.courseColorsForPreview[event.course.id]!.toColor()
                                            )
                                        }
                                    })
                                }
                                .padding(.bottom, 35)
                            }
                        }
                    }
                }
                .padding(.horizontal, 7.5)
            }
        }
    }
    
    func createDays() -> [DayUiModel]? {
        if let days = viewModel.schedule?.flatten() {
            return days.toOrderedDayUiModels()
        } else {
            return nil
        }
    }
}
