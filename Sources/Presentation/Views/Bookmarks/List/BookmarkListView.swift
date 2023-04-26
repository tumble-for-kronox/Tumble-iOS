//
//  ScheduleGrouperView.swift
//  Tumble
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
    @State private var bookmarksListModel: BookmarksListModel = .init()
    @State private var searching: Bool = false
    @State private var searchText: String = ""
    @State private var showSearchField: Bool = true
    
    var scrollSpace: String = "bookmarksRefreshable"
    
    var filteredEvents: [Event] {
        if searchText.isEmpty {
            return days.flatMap { $0.events }.filter { $0.isValidEvent() }.removeDuplicates()
        } else {
            return days.flatMap { $0.events.filter { event in
                let titleMatches = event.title.localizedCaseInsensitiveContains(searchText)
                let courseNameMatches = event.course?.englishName.localizedCaseInsensitiveContains(searchText) ?? false
                return (titleMatches || courseNameMatches) && event.isValidEvent()
            }}.removeDuplicates()
        }
    }
    
    var body: some View {
        VStack {
            if showSearchField {
                SearchField(
                    search: nil,
                    clearSearch: nil,
                    title: "Search events",
                    searchBarText: $searchText,
                    searching: $searching,
                    disabled: .constant(false)
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
                LazyVStack(alignment: .center) {
                    listUnfiltered
                }
                .padding(.top, 15)
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
                ToTopButton(buttonOffsetX: bookmarksListModel.buttonOffsetX, value: value),
                alignment: .bottomTrailing
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
                                        isLast: event == day.events.last
                                    )
                                    .padding(.horizontal, 15)
                                }
                            })
                        }
                    }
                }
                .padding(.vertical, 20)
            }
        }
    }
    
    var listSearching: some View {
        ScrollView(.vertical, showsIndicators: false) {
            LazyVStack(alignment: .center) {
                if filteredEvents.isEmpty {
                    Info(title: NSLocalizedString("No events match your search", comment: ""), image: nil)
                } else {
                    ForEach(filteredEvents, id: \._id) { event in
                        BookmarkCard(
                            onTapCard: onTapCard,
                            event: event,
                            isLast: true
                        )
                        .padding(.horizontal, 15)
                    }
                }
            }
            .padding(7.5)
        }
    }
    
    fileprivate func onTapCard(event: Event) {
        appController.eventSheet = EventDetailsSheetModel(event: event)
    }
    
    fileprivate func handleButtonAnimation() {
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
    
    fileprivate func handleSearchFieldVisibility() {
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
    
    fileprivate func handleScrollOffset(value: CGFloat) {
        if bookmarksListModel.startOffset == 0 {
            bookmarksListModel.startOffset = value
        }
        let offset = value
        bookmarksListModel.scrollViewOffset = offset - bookmarksListModel.startOffset
    }
}
