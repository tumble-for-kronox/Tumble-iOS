//
//  SchedulePreviewView.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 11/18/22.
//

import SwiftUI

struct SchedulePreviewView: View {
    @EnvironmentObject var parentViewModel: SearchParentView.SearchViewModel
    @StateObject var viewModel: SchedulePreviewViewModel = SchedulePreviewViewModel()
    var body: some View {
        if (parentViewModel.previewDelegateStatus == .loaded) {
            let courseColors = parentViewModel.scheduleForPreview!.assignCoursesColors();
            SchedulePreviewGrouperListView(toggled: parentViewModel.schedulePreviewIsSaved, courseColors: courseColors, days: parentViewModel.scheduleForPreview!.days.toUiModel()) {
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


