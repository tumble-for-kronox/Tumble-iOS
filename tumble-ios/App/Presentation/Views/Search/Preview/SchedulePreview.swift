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
    
    var body: some View {
        VStack {
            switch parentViewModel.schedulePreviewStatus {
            case .loaded:
                if courseColors != nil {
                    SchedulePreviewList(
                        parentViewModel: parentViewModel,
                        courseColors: courseColors!,
                        days: parentViewModel.scheduleListOfDays!)
                } else {
                    CustomProgressIndicator()
                }
            case .loading:
                CustomProgressIndicator()
            case .error:
                if let failure = parentViewModel.errorMessagePreview {
                    Info(title: failure, image: nil)
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
        .background(Color.background)
    }
}

