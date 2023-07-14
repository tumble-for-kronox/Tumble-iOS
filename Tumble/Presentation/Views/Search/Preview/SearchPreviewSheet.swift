//
//  SchedulePreviewView.swift
//  Tumble
//
//  Created by Adis Veletanlic on 11/18/22.
//

import RealmSwift
import SwiftUI
import WidgetKit

struct SearchPreviewSheet: View {
    @ObservedObject var viewModel: SearchPreviewViewModel
    @ObservedResults(Schedule.self, configuration: realmConfig) var schedules
    
    let programmeId: String
    let schoolId: String
    
    var body: some View {
        VStack {
            DraggingPill()
            if viewModel.status == .loaded {
                HStack {
                    Spacer()
                    BookmarkButton(
                        bookmark: bookmark,
                        buttonState: $viewModel.buttonState
                    )
                }
            }
            switch viewModel.status {
            case .loaded:
                SearchPreviewList(
                    viewModel: viewModel
                )
            case .loading:
                CustomProgressIndicator()
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            case .error:
                if let failure = viewModel.errorMessage {
                    Info(title: failure, image: nil)
                } else {
                    Info(title: NSLocalizedString("Something went wrong", comment: ""), image: nil)
                }
            case .empty:
                Info(title: NSLocalizedString("Schedule seems to be empty", comment: ""), image: nil)
            }
        }
        .frame(
            minWidth: 0,
            maxWidth: .infinity,
            minHeight: 0,
            maxHeight: .infinity,
            alignment: .center
        )
        .background(Color.background)
        .onAppear {
            viewModel.getSchedule(
                programmeId: programmeId,
                schoolId: schoolId,
                schedules: Array(schedules)
            )
        }
    }
    
    func bookmark() {
        viewModel.bookmark(
            scheduleId: programmeId,
            schedules: Array(schedules),
            schoolId: schoolId
        )
        WidgetCenter.shared.reloadAllTimelines()
    }
}
