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
    @State private var searching: Bool = false
    @State private var searchText: String = ""
    @State private var showSearchField: Bool = true
    
    var scrollSpace: String = "bookmarksRefreshable"
    
    var filteredEvents: [Response.Event] {
        if searchText.isEmpty {
            return []
        } else {
            var events: [Response.Event] = []
            for day in days {
                let filteredDayEvents = day.events.filter { event in
                    let titleMatches = event.title.localizedCaseInsensitiveContains(searchText)
                    let courseNameMatches = event.course.englishName.localizedCaseInsensitiveContains(searchText)
                    return titleMatches || courseNameMatches
                }
                events.append(contentsOf: filteredDayEvents)
            }
            return events
        }
    }
    
    var body: some View {
        VStack {
            if showSearchField {
                SearchField(
                    search: nil,
                    title: "Search events",
                    searchBarText: $searchText,
                    searching: $searching
                )
            }
            if !searching {
                ScrollViewReader { value in
                    ScrollView(.vertical, showsIndicators: false) {
                        LazyVStack (alignment: .center) {
                            ForEach(days, id: \.id) { day in
                                if !(day.events.isEmpty) {
                                    Section(header: DayHeader(day: day), content: {
                                        ForEach(day.events.sorted(), id: \.id) { event in
                                            BookmarkCard(
                                                onTapCard: onTapCard,
                                                event: event,
                                                isLast: event == day.events.last,
                                                color: courseColors[event.course.id] != nil ?
                                                courseColors[event.course.id]!.toColor() : .white)
                                        }
                                    })
                                }
                            }
                        }
                        .padding(7.5)
                        .overlay(
                            GeometryReader { proxy -> Color in
                                DispatchQueue.main.async {
                                    handleScrollOffset(value: proxy.frame(in: .global).minY)
                                    handleButtonAnimation()
                                    handleSearchFieldVisibility()
                                }
                                return Color.clear
                            }
                        )
                        .id("bookmarkScrollView")
                    }
                    .overlay(
                        ToTopButton(buttonOffsetX: bookmarksListModel.buttonOffsetX, value: value)
                        ,alignment: .bottomTrailing
                    )
                }
            } else {
                ScrollView(.vertical, showsIndicators: false) {
                    LazyVStack (alignment: .center) {
                        ForEach(filteredEvents, id: \.id) { event in
                            BookmarkCard(
                                onTapCard: onTapCard,
                                event: event,
                                isLast: true,
                                color: courseColors[event.course.id] != nil ?
                                courseColors[event.course.id]!.toColor() : .white)
                        }
                    }
                    .padding(7.5)
                }
            }
        }
        .ignoresSafeArea(.keyboard)
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
    
    fileprivate func handleSearchFieldVisibility() -> Void {
        if -bookmarksListModel.scrollViewOffset > 100 && !searching {
            withAnimation(.easeInOut) {
                showSearchField = false
            }
        } else if -bookmarksListModel.scrollViewOffset < 100 && !searching {
            withAnimation(.easeInOut) {
                showSearchField = true
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
