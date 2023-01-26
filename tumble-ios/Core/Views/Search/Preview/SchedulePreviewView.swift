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
        if (parentViewModel.previewDelegateStatus == .loaded) {
            let courseColors = parentViewModel.scheduleForPreview!.assignRandomCoursesColors();
            SchedulePreviewListView(toggled: parentViewModel.schedulePreviewIsSaved, randomCourseColors: courseColors, existingCourseColors: parentViewModel.courseColors, days: parentViewModel.scheduleListOfDays!) {
                parentViewModel.onBookmark(courseColors: courseColors)
            }
        }
        if (parentViewModel.previewDelegateStatus == .loading) {
            Spacer()
            CustomProgressView()
            Spacer()
        }
        if (parentViewModel.previewDelegateStatus == .error || parentViewModel.previewDelegateStatus == .empty) {
            Text("Error!")
        }
    }
}


