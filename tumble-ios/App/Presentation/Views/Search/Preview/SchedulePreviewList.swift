//
//  SchedulePreviewGrouperListView.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 2022-12-02.
//

import SwiftUI
import Combine

enum ButtonState {
    case loading
    case saved
    case notSaved
}

struct SchedulePreviewList: View {
            
    @ObservedObject var parentViewModel: SearchViewModel
    let courseColors: [String : String]
    let checkForNewSchedules: () -> Void
    let days: [DayUiModel]
    
    @State var disableButton: Bool = false
    
    init(
        parentViewModel: SearchViewModel,
        courseColors: [String : String],
        days: [DayUiModel],
        checkForNewSchedules: @escaping () -> Void) {
            
        self.parentViewModel = parentViewModel
        self.courseColors = courseColors
        self.days = days
        self.checkForNewSchedules = checkForNewSchedules
    }
    
    var body: some View {
        ZStack {
            ScrollView (showsIndicators: false) {
                LazyVStack (spacing: 0) {
                    ForEach(days, id: \.id) { day in
                        if !(day.events.isEmpty) {
                            Section(header: DayHeader(day: day), content: {
                                ForEach(day.events, id: \.id) { event in
                                    VerboseEventButtonLabel(
                                        event: event,
                                        color: courseColors[event.course.id]!.toColor()
                                    )
                                }
                            })
                            .padding(.top, 35)
                        }
                    }
                    
                }
                .padding(7.5)
            }
            VStack (alignment: .leading) {
                Spacer()
                HStack {
                    BookmarkButton(
                        bookmark: bookmark,
                        disableButton: $disableButton,
                        previewButtonState: $parentViewModel.previewButtonState
                    )
                    Spacer()
                }
            }
        }
    }
    
    func bookmark() -> Void {
        if self.parentViewModel.previewButtonState != .loading {
            self.disableButton = true            
            self.parentViewModel.onBookmark(updateButtonState: {
                DispatchQueue.main.async {
                    self.disableButton = false
                }
            }, checkForNewSchedules: self.checkForNewSchedules)
        }
    }
}
