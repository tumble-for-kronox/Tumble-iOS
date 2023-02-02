//
//  SchedulePreviewView.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 11/18/22.
//

import SwiftUI

struct SchedulePreviewView: View {
    @EnvironmentObject var parentViewModel: SearchParentView.SearchViewModel
    @Binding var courseColors: [String : String]?
    
    let checkForNewSchedules: CheckForNewSchedules
    
    var body: some View {
        switch parentViewModel.schedulePreviewStatus {
        case .loaded:
            if courseColors != nil {
                SchedulePreviewListView(toggled: parentViewModel.schedulePreviewIsSaved, courseColors: courseColors!, days: parentViewModel.scheduleListOfDays!) {
                    parentViewModel.onBookmark(checkForNewSchedules: {
                        checkForNewSchedules()
                    })
                }
            } else {
                CustomProgressView()
            }
        case .loading:
            CustomProgressView()
        case .error:
            InfoView(title: "Something went wrong", image: "wifi.exclamationmark")
        case .empty:
            InfoView(title: "Schedule seems to be empty", image: "questionmark.bubble")
        }
    }
}


