//
//  ScheduleGrouperView.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 11/21/22.
//

import SwiftUI

typealias OnTapCard = (Response.Event, Color) -> Void


struct BookmarkListView: View {
    
    let days: [DayUiModel]
    let courseColors: CourseAndColorDict
    let onTapCard: OnTapCard
    @State private var scrollViewOffset: CGFloat = .zero
    @State private var startOffset: CGFloat = .zero
    @State private var buttonOffsetX: CGFloat = 200
    
    
    var body: some View {
        ScrollViewReader { value in
            ScrollView(.vertical) {
                LazyVStack {
                    Rectangle().foregroundColor(.clear).frame(height: 1.0)
                    ForEach(days, id: \.id) { day in
                        if !(day.events.isEmpty) {
                            Section(header: DayHeader(day: day), content: {
                                ForEach(day.events, id: \.id) { event in
                                    ScheduleCard(onTapCard: onTapCard, event: event, isLast: event == day.events.last, color: courseColors[event.course.id] != nil ? courseColors[event.course.id]!.toColor() : "FFFFFF".toColor())
                                }
                            })
                            .padding(.top, 35)
                        }
                    }
                    
                }
                .id("TOP")
                .padding(7.5)
                .overlay(
                    GeometryReader { proxy -> Color in
                        DispatchQueue.main.async {
                            if startOffset == 0 {
                                self.startOffset = proxy.frame(in: .global).minY
                            }
                            let offset = proxy.frame(in: .global).minY
                            
                            self.scrollViewOffset = offset - startOffset
                            if -self.scrollViewOffset > 450 {
                                withAnimation(.spring()) {
                                    buttonOffsetX = .zero
                                }
                            } else if -scrollViewOffset < 450 {
                                withAnimation(.spring()) {
                                    buttonOffsetX = 200
                                }
                            }
                        }
                        return Color.clear
                    }
                )
                
            }
            .overlay(
                Button(action: {
                    withAnimation(.spring()) {
                        value.scrollTo("TOP", anchor: .top)
                    }
                }, label: {
                    Image(systemName: "arrow.up")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(.background)
                        .padding()
                        .background(Color.primary)
                        .clipShape(Circle())
                })
                .padding()
                .offset(x: buttonOffsetX)
                .shadow(radius: 5, x: 5, y: 5)
                ,alignment: .bottomTrailing
            )
        }
    }
}
