//
//  ScheduleGrouperView.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 11/21/22.
//

import SwiftUI

struct ScheduleGrouperListView: View {
    let days: [DayUiModel]
    var body: some View {
        ZStack {
            ScrollView {
                LazyVStack (spacing: 0) {
                    ForEach(days, id: \.id) { day in
                        if !(day.events.isEmpty) {
                            Section(header: DayHeaderSectionView(day: day), content: {
                                ForEach(day.events, id: \.id) { event in
                                    ScheduleCardView(event: event)
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
                            // Stub
                        }) {
                            HStack {
                                Image(systemName: "bookmark")
                                    .font(.system(size: 20))
                                    .foregroundColor(Color("OnPrimary"))
                                Text("Bookmark")
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
