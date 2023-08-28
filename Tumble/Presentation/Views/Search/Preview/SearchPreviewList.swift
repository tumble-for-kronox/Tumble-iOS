//
//  SchedulePreviewGrouperListView.swift
//  Tumble
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
            VStack(spacing: 10) {
                ForEach(createDays() ?? [], id: \.id) { day in
                    if !day.events.isEmpty {
                        VStack {
                            DayResponseHeader(day: day)
                            ForEach(day.events, id: \.id) { event in
                                VerboseEventResponseButtonLabel(
                                    event: event,
                                    color: viewModel.courseColorsForPreview[event.course.id]?.toColor() ?? .white
                                )
                                .padding(.bottom, 10)
                            }
                        }
                        .padding(.vertical, 20)
                    }
                }
            }
            .padding(.horizontal, 15)
        }
    }
    
    func createDays() -> [Response.Day]? {
        return viewModel.schedule?.flatten().ordered()
    }
}
