//
//  SchedulePreviewView.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 11/18/22.
//

import SwiftUI

struct SchedulePreviewView: View {
    @EnvironmentObject var parentViewModel: SearchView.SearchViewModel
    @StateObject var viewModel: SchedulePreviewViewModel = SchedulePreviewViewModel()
    var body: some View {
        if (parentViewModel.previewDelegateStatus == .loaded) {
            ScrollView {
                LazyVStack {
                    ForEach(parentViewModel.scheduleForPreview!.days.toEvents(), id: \.id) { event in
                        ScheduleCardView(event: event)
                    }
                }
            }
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

