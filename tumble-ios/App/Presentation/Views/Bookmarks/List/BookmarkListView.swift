//
//  ScheduleGrouperView.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 11/21/22.
//

import SwiftUI


struct BookmarksListModel {
    var scrollViewOffset: CGFloat = .zero
    var startOffset: CGFloat = .zero
    var buttonOffsetX: CGFloat = 200
}

struct BookmarkListView: View {
    
    let days: [DayUiModel]
    let courseColors: CourseAndColorDict
    @ObservedObject var appController: AppController
    @State private var bookmarksListModel: BookmarksListModel = BookmarksListModel()
    
    var body: some View {
        ScrollViewReader { value in
            ScrollView(.vertical, showsIndicators: false) {
                LazyVStack {
                    Rectangle().foregroundColor(.clear).frame(height: 1.0)
                    ForEach(days, id: \.id) { day in
                        if !(day.events.isEmpty) {
                            Section(header: DayHeader(day: day), content: {
                                ForEach(day.events, id: \.id) { event in
                                    BookmarkCard(
                                        onTapCard: onTapCard,
                                        event: event,
                                        isLast: event == day.events.last,
                                        color: courseColors[event.course.id] != nil ?
                                        courseColors[event.course.id]!.toColor() : .white)
                                }
                            })
                            .padding(.top)
                        }
                    }
                }
                .padding(7.5)
                .overlay(
                    GeometryReader { proxy -> Color in
                        DispatchQueue.main.async {
                            handleScrollOffset(value: proxy.frame(in: .global).minY)
                            handleButtonAnimation()
                        }
                        return Color.clear
                    }
                )
                .id("bookmarkScrollView")
            }
            .overlay(
                Button(action: {
                    withAnimation(.spring()) {
                        value.scrollTo("bookmarkScrollView", anchor: .top)
                    }
                }, label: {
                    Image(systemName: "arrow.up")
                        .font(.system(size: 24, weight: .semibold))
                        .foregroundColor(.background)
                        .padding(15)
                        .background(Color.primary)
                        .clipShape(Rectangle())
                        .cornerRadius(20)
                })
                .padding()
                .offset(x: bookmarksListModel.buttonOffsetX)
                ,alignment: .bottomTrailing
            )
        }
    }
    
    fileprivate func onTapCard(event: Response.Event, color: Color) -> Void {
        appController.eventSheet = EventDetailsSheetModel(event: event, color: color)
    }
    
    fileprivate func handleButtonAnimation() -> Void {
        if -bookmarksListModel.scrollViewOffset > 450 {
            withAnimation(.spring()) {
                bookmarksListModel.buttonOffsetX = .zero
            }
        } else if -bookmarksListModel.scrollViewOffset < 450 {
            withAnimation(.spring()) {
                bookmarksListModel.buttonOffsetX = 200
            }
        }
    }
    
    fileprivate func handleScrollOffset(value: CGFloat) -> Void {
        if bookmarksListModel.startOffset == 0 {
            bookmarksListModel.startOffset = value
        }
        let offset = value
        
        bookmarksListModel.scrollViewOffset = offset - bookmarksListModel.startOffset
    }
}
