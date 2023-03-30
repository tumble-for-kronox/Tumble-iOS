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
                if let error = parentViewModel.errorMessagePreview {
                    Info(title: error, image: nil)
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
        .background(Color(UIColor.systemBackground))
    }
}

