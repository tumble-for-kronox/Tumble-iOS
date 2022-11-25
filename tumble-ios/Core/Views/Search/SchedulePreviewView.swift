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
            ScheduleGrouperListView(days: parentViewModel.scheduleForPreview!.days.toUiModel())
        }
        if (parentViewModel.previewDelegateStatus == .loading) {
            CustomProgressView()
        }
        if (parentViewModel.previewDelegateStatus == .error) {
            Text("Error!")
        }
        if (parentViewModel.previewDelegateStatus == .empty) {
            Text("Schedule is empty!")
        }
    }
}

