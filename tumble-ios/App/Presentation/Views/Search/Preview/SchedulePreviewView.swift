//
//  SchedulePreviewView.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 11/18/22.
//

import SwiftUI

struct SchedulePreviewView: View {
    @EnvironmentObject var parentViewModel: SearchParentView.SearchViewModel
    let checkForNewSchedules: CheckForNewSchedules
    var body: some View {
        switch parentViewModel.schedulePreviewStatus {
        case .loaded:
            let courseColors = parentViewModel.scheduleForPreview!.assignCoursesRandomColors()
            SchedulePreviewListView(toggled: parentViewModel.schedulePreviewIsSaved, randomCourseColors: courseColors, existingCourseColors: parentViewModel.courseColors, days: parentViewModel.scheduleListOfDays!) {
                parentViewModel.onBookmark(courseColors: courseColors, checkForNewSchedules: {
                    checkForNewSchedules()
                })
            }
        case .loading:
            Spacer()
            CustomProgressView()
            Spacer()
        case .error:
            InfoView(title: "Something went wrong on KronoX", image: "wifi.exclamationmark")
        case .empty:
            InfoView(title: "Schedule seems to be empty", image: "questionmark.bubble")
        }
    }
}


