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

struct SchedulePreviewListView: View {
    
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
                            Section(header: DayHeaderSectionView(day: day), content: {
                                ForEach(day.events, id: \.id) { event in
                                    SchedulePreviewCardView(
                                        previewColor: hexStringToUIColor(hex: courseColors[event.course.id]!), event: event, isLast: event == day.events.last)
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
                                    CustomProgressView()
                                        .matchedGeometryEffect(id: "BOOKMARKBTN", in: animation)
                                case .saved:
                                    Image(systemName: "bookmark.fill")
                                        .font(.system(size: 20))
                                        .foregroundColor(.onPrimary)
                                        .matchedGeometryEffect(id: "BOOKMARKBTN", in: animation)
                                case .notSaved:
                                    Image(systemName: "bookmark")
                                        .font(.system(size: 20))
                                        .foregroundColor(.onPrimary)
                                        .matchedGeometryEffect(id: "BOOKMARKBTN", in: animation)
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
