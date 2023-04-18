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
    
    let days: [Day]
    @ObservedObject var appController: AppController
    @State private var bookmarksListModel: BookmarksListModel = BookmarksListModel()
    @State private var searching: Bool = false
    @State private var searchText: String = ""
    @State private var showSearchField: Bool = true
    
    var scrollSpace: String = "bookmarksRefreshable"
    
    var filteredEvents: [Event] {
        if searchText.isEmpty {
            return []
        } else {
            var events: [Event] = []
            for day in days {
                if day.isValidDay() {
                    let filteredDayEvents = day.events.filter { event in
                        let titleMatches = event.title.localizedCaseInsensitiveContains(searchText)
                        let courseNameMatches = event.course?.englishName.localizedCaseInsensitiveContains(searchText)
                        return titleMatches || (courseNameMatches != nil)
                    }
                    events.append(contentsOf: filteredDayEvents)
                }
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
                listNotSearching
            } else {
                listSearching
            }
        }
        .ignoresSafeArea(.keyboard)
    }
    
    var listNotSearching: some View {
        ScrollViewReader { value in
            ScrollView(.vertical, showsIndicators: false) {
                LazyVStack (alignment: .center) {
                    listUnfiltered
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
    }
    
    var listUnfiltered: some View {
        ForEach(days, id: \._id) { day in
            if !(day.events.isEmpty) {
                VStack {
                    if day.isValidDay() {
                        VStack {
                            Section(header: DayHeader(day: day), content: {
                                ForEach(Array(day.events).sorted(), id: \._id) { event in
                                    BookmarkCard(
                                        onTapCard: onTapCard,
                                        event: event,
                                        isLast: event == day.events.last)
                                }
                            })
                        }
                        .padding(.vertical, 15)
                    }
                }
                .padding(.top, 5)
            }
        }
    }
    
    var listSearching: some View {
        ScrollView(.vertical, showsIndicators: false) {
            LazyVStack (alignment: .center) {
                ForEach(filteredEvents, id: \._id) { event in
                    BookmarkCard(
                        onTapCard: onTapCard,
                        event: event,
                        isLast: true)
                }
            }
            .padding(7.5)
        }
    }
    
    fileprivate func onTapCard(event: Event) -> Void {
        appController.eventSheet = EventDetailsSheetModel(event: event)
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
