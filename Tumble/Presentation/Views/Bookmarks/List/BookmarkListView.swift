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
                VStack {
                    Spacer()
                        .frame(height: 60)
                    ForEach(days, id: \._id) { day in
                        LazyVStack {
                            VStack {
                                Section(header: DayHeader(day: day), content: {
                                    ForEach(day.events, id: \._id) { event in
                                        BookmarkCard(
                                            onTapCard: onTapCard,
                                            event: event,
                                            isLast: event == day.events.last
                                        )
                                        .padding(.horizontal, 15)
                                    }
                                })
                            }
                            .padding(.vertical, 15)
                        }
                    }
                }
                .padding(.top, 2.5)
                .id("bookmarkScrollView")
            }
            .overlay(
                ToTopButton(buttonOffsetX: bookmarksListModel.buttonOffsetX, proxy: proxy),
                alignment: .bottomTrailing
            )
        }
        .ignoresSafeArea(.keyboard)
    }
    
    fileprivate func onTapCard(event: Event) {
        appController.eventSheet = EventDetailsSheetModel(event: event)
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
