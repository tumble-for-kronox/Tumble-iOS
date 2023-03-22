//
//  SchedulePreviewView.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 11/18/22.
//

import SwiftUI

struct SchedulePreview: View {
    
    @ObservedObject var parentViewModel: SearchViewModel
    @Binding var courseColors: [String : String]?
    let checkForNewSchedules: () -> Void
    
    var body: some View {
        VStack {
            switch parentViewModel.schedulePreviewStatus {
            case .loaded:
                if courseColors != nil {
                    SchedulePreviewList(
                        parentViewModel: parentViewModel,
                        courseColors: courseColors!,
                        days: parentViewModel.scheduleListOfDays!,
                        checkForNewSchedules: checkForNewSchedules)
                } else {
                    CustomProgressIndicator()
                }
            case .loading:
                CustomProgressIndicator()
            case .error:
                if let error = parentViewModel.errorMessage {
                    Info(title: error, image: "wifi.exclamationmark")
                } else {
                    Info(title: "Something went wrong", image: "wifi.exclamationmark")
                }
            case .empty:
                Info(title: "Schedule seems to be empty", image: "questionmark.bubble")
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
    }
}

