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
            SchedulePreviewGrouperListView(toggled: parentViewModel.schedulePreviewIsSaved, previewCourseColors: parentViewModel.scheduleForPreview!.assignCoursesColors(), days: parentViewModel.scheduleForPreview!.days.toUiModel()) {
                parentViewModel.onBookmark()
            }
        }
        if (parentViewModel.previewDelegateStatus == .loading) {
            CustomProgressView()
        }
        if (parentViewModel.previewDelegateStatus == .error || parentViewModel.previewDelegateStatus == .empty) {
            Text("Error!")
        }
    }
}


