//
//  SchedulePreviewView.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 11/18/22.
//

import SwiftUI

struct SchedulePreviewView: View {
    @EnvironmentObject var parentViewModel: SearchParentView.SearchViewModel
    var body: some View {
        if (parentViewModel.schedulePreviewStatus == .loaded) {
            let courseColors = parentViewModel.scheduleForPreview!.assignCoursesRandomColors()
            SchedulePreviewListView(toggled: parentViewModel.schedulePreviewIsSaved, randomCourseColors: courseColors, existingCourseColors: parentViewModel.courseColors, days: parentViewModel.scheduleListOfDays!) {
                parentViewModel.onBookmark(courseColors: courseColors)
            }
        }
        if (parentViewModel.schedulePreviewStatus == .loading) {
            Spacer()
            CustomProgressView()
            Spacer()
        }
        if (parentViewModel.schedulePreviewStatus == .error || parentViewModel.schedulePreviewStatus == .empty) {
            Text("Error!")
        }
    }
}


