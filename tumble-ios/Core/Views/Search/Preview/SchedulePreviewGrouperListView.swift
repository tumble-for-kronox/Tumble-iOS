//
//  SchedulePreviewGrouperListView.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 2022-12-02.
//

import SwiftUI

struct SchedulePreviewGrouperListView: View {
    @State var toggled: Bool
    let previewCourseColors: [String : Color]
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
                                    SchedulePreviewCardView(previewColor: previewCourseColors[event.course.id]!, event: event, isLast: event == day.events.last)
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
                        toggled.toggle()
                        self.bookmark!()
                        }) {
                            HStack {
                                Image(systemName: toggled ? "bookmark.fill" : "bookmark")
                                    .font(.system(size: 20))
                                    .foregroundColor(Color("OnPrimary"))
                                Text(toggled ? "Un-bookmark" : "Bookmark")
                                    .font(.headline)
                                    .foregroundColor(Color("OnPrimary"))
                            }
                            .padding()
                            
                        }
                        .background(Color("PrimaryColor"))
                        .cornerRadius(10)
                        .padding(15)
                        .padding(.leading, 5)
                    Spacer()
                }
            }
        }
    }
}
