//
//  SchedulePreviewGrouperListView.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 2022-12-02.
//

import SwiftUI

enum ButtonState {
    case loading
    case saved
    case notSaved
}

struct SchedulePreviewList: View {
    
    @Namespace var animation
    
    @Binding var buttonState: ButtonState
    let courseColors: [String : String]
    let days: [DayUiModel]
    let bookmark: (() -> Void)?
    
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
                    Button(action: {
                        if buttonState != .loading {
                            withAnimation {
                                buttonState = .loading
                            }
                            self.bookmark!()
                        }
                        }) {
                            HStack {
                                switch buttonState {
                                case .loading:
                                    CustomProgressIndicator()
                                        .matchedGeometryEffect(id: "BOOKMARKBTN", in: animation)
                                case .saved:
                                    BookmarkButton(animation: animation, title: "Remove", image: "bookmark.fill")
                                case .notSaved:
                                    BookmarkButton(animation: animation, title: "Bookmark", image: "bookmark")
                                }
                            }
                            .padding()
                            
                        }
                        .background(Color.primary)
                        .cornerRadius(10)
                        .padding(15)
                        .padding(.leading, 5)
                    Spacer()
                }
            }
        }
    }
}
