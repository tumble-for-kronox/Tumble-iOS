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
    
    @Namespace var animation
        
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
            ScrollView {
                LazyVStack (spacing: 0) {
                    ForEach(days, id: \.id) { day in
                        if !(day.events.isEmpty) {
                            Section(header: DayHeader(day: day), content: {
                                ForEach(day.events, id: \.id) { event in
                                    SchedulePreviewCard(
                                        previewColor: courseColors[event.course.id]!.toColor(), event: event, isLast: event == day.events.last)
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
                    Button(action: bookmark) {
                        HStack {
                            switch self.parentViewModel.previewButtonState {
                            case .loading:
                                CustomProgressIndicator(tint: .onPrimary)
                            case .saved:
                                BookmarkButton(animation: animation, title: "Remove", image: "bookmark.fill")
                            case .notSaved:
                                BookmarkButton(animation: animation, title: "Bookmark", image: "bookmark")
                            }
                        }
                        .frame(minWidth: 80)
                        .padding()
                    }
                    .id(self.parentViewModel.previewButtonState)
                    .background(Color.primary)
                    .cornerRadius(10)
                    .padding(15)
                    .padding(.leading, 5)
                    .disabled(disableButton)
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
