//
//  SchedulePreviewView.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 11/18/22.
//

import SwiftUI

struct SchedulePreview: View {
    
    @EnvironmentObject var parentViewModel: SearchViewModel
    @Binding var courseColors: [String : String]?
    let checkForNewSchedules: () -> Void
    @State var buttonState: ButtonState = .loading
    
    var body: some View {
        switch parentViewModel.schedulePreviewStatus {
        case .loaded:
            if courseColors != nil {
                SchedulePreviewList(buttonState: $buttonState, courseColors: courseColors!, days: parentViewModel.scheduleListOfDays!, bookmark: {
                    let newButtonState = parentViewModel.onBookmark(checkForNewSchedules: checkForNewSchedules)
                    withAnimation {
                        self.buttonState = newButtonState
                    }
                })
                .onAppear(perform: setButtonState)
            } else {
                CustomProgressIndicator()
            }
        case .loading:
            CustomProgressIndicator()
        case .error:
            Info(title: "Something went wrong", image: "wifi.exclamationmark")
        case .empty:
            Info(title: "Schedule seems to be empty", image: "questionmark.bubble")
        }
    }
    
    func setButtonState() -> Void {
        if parentViewModel.schedulePreviewIsSaved {
            buttonState = .saved
        } else {
            buttonState = .notSaved
        }
    }
    
}

