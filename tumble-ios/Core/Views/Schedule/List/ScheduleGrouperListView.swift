//
//  ScheduleGrouperView.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 11/21/22.
//

import SwiftUI

struct ScheduleGrouperListView: View {
    @State var toggled: Bool?
    let previewCourseColors: [String : Color]?
    let days: [DayUiModel]
    let inPreview: Bool
    let bookmark: (() -> Void)?
    var body: some View {
        ZStack {
            ScrollView {
                LazyVStack (spacing: 0) {
                    ForEach(days, id: \.id) { day in
                        if !(day.events.isEmpty) {
                            Section(header: DayHeaderSectionView(day: day), content: {
                                ForEach(day.events, id: \.id) { event in
                                    ScheduleCardView(previewColor: inPreview ? previewCourseColors![event.course.id] : nil, event: event, isLast: event == day.events.last)
                                }
                            })
                            .padding(.top, 35)
                        }
                    }
                    
                }
                .padding(7.5)
            }
            if inPreview {
                VStack (alignment: .leading) {
                    Spacer()
                    HStack {
                        Button(action: {
                            toggled!.toggle()
                            self.bookmark!()
                            }) {
                                HStack {
                                    Image(systemName: toggled! ? "bookmark.fill" : "bookmark")
                                        .font(.system(size: 20))
                                        .foregroundColor(Color("OnPrimary"))
                                    Text(toggled! ? "Un-bookmark" : "Bookmark")
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
}
