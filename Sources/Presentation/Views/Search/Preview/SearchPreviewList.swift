//
//  SchedulePreviewGrouperListView.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 2022-12-02.
//

import Combine
import SwiftUI

enum ButtonState {
    case loading
    case saved
    case notSaved
    case disabled
}

struct SearchPreviewList: View {
    @ObservedObject var viewModel: SearchPreviewViewModel
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 0) {
                ForEach(createDays() ?? [], id: \.date) { day in
                    if !day.events.isEmpty {
                        VStack {
                            DayResponseHeader(day: day)
                            ForEach(day.events, id: \.id) { event in
                                VerboseEventResponseButtonLabel(
                                    event: event,
                                    color: viewModel.courseColorsForPreview[event.course.id]!.toColor()
                                )
                            }
                        }
                        .padding(.bottom, 35)
                    }
                }
            }
            .padding(.horizontal, 7.5)
        }
    }
    
    func createDays() -> [Response.Day]? {
        return viewModel.schedule?.flatten().ordered()
    }
}
