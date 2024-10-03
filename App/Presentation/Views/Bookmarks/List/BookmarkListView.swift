//
//  ScheduleGrouperView.swift
//  Tumble
//
//  Created by Adis Veletanlic on 11/21/22.
//

import SwiftUI
import RealmSwift

enum BookmarkListState {
    case searching
    case notSearching
}

struct BookmarksListModel {
    var scrollViewOffset: CGFloat = .zero
    var startOffset: CGFloat = .zero
    var buttonOffsetX: CGFloat = 0
    var state: BookmarkListState = .notSearching
}

struct BookmarkListView: View {
    let days: [Day]
    @ObservedObject var appController: AppController
    @State private var bookmarksListModel: BookmarksListModel = .init()
    
    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                DaysList(days: days)
                    .id("bookmarkScrollView")
            }
            .overlay(
                ToTopButton(buttonOffsetX: bookmarksListModel.buttonOffsetX, proxy: proxy),
                alignment: .bottomTrailing
            )
        }
        .ignoresSafeArea(.keyboard)
    }
    
    fileprivate func onChangeSearch(searching: Bool) {
        withAnimation(.easeInOut) {
            if searching {
                bookmarksListModel.state = .searching
            } else {
                bookmarksListModel.state = .notSearching
            }
        }
    }
}

private struct EventList: View {
    let events: RealmSwift.List<Event>
    
    var body: some View {
        ForEach(events.sorted(by: EventSorting.sortedEventOrder), id: \._id) { event in
            BookmarkCard(
                onTapCard: onTapCard,
                event: event,
                isLast: event == events.last
            )
            .padding(.horizontal, 15)
        }
    }
    
    fileprivate func onTapCard(event: Event) {
        AppController.shared.eventSheet = EventDetailsSheetModel(event: event)
    }
}

private struct DaysList: View {
    let days: [Day]
    
    var body: some View {
        ForEach(days, id: \._id) { day in
            LazyVStack {
                VStack {
                    Section(header: DayHeader(day: day), content: {
                        EventList(events: day.events)
                    })
                }
                .padding(.vertical, 15)
            }
        }
    }
}
