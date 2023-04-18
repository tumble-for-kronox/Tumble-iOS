//
//  SchedulePageMainView.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 11/21/22.
//

import SwiftUI

struct Bookmarks: View {
    
    @ObservedObject var viewModel: BookmarksViewModel
    @ObservedObject var parentViewModel: ParentViewModel
    @ObservedObject var appController: AppController = AppController.shared
    
    var body: some View {
        VStack (alignment: .center) {
            VStack {
                ViewSwitcher(parentViewModel: viewModel)
                switch viewModel.status {
                case .loading:
                    Spacer()
                    HStack {
                        Spacer()
                        CustomProgressIndicator()
                        Spacer()
                    }
                    Spacer()
                case .loaded:
                    let days = createDays()
                    switch viewModel.defaultViewType {
                    case .list:
                        BookmarkListView(
                            days: days,
                            appController: appController
                        )
                    case .calendar:
                        BookmarkCalendarView(
                            appController: appController,
                            days: days
                        )
                    }
                case .uninitialized:
                    Info(title: NSLocalizedString("No bookmarks yet", comment: ""), image: "bookmark.slash")
                case .error:
                    Info(title: NSLocalizedString("There was an error retrieving your schedules", comment: ""), image: "exclamationmark.circle")
                case .hiddenAll:
                    Info(title: NSLocalizedString("All your bookmarks are hidden", comment: ""), image: "bookmark.slash")
                }
            }
        }
        .padding(.top, 10)
        .background(Color.background)
        .padding(.bottom, -10)
        .onAppear {
            UIApplication.shared.applicationIconBadgeNumber = 0
        }
        // Event sheet for both when a notification has been opened outside
        // the application by the user and when triggered on click of event card.
        // The shared eventSheet value is changed from AppDelegate and launched here,
        // as well as in this view if an event is pressed.
        .sheet(item: $appController.eventSheet) { (eventSheet: EventDetailsSheetModel) in
            EventDetailsSheet(
                viewModel: viewModel.createViewModelEventSheet(
                    event: eventSheet.event))
        }
    }
    
    func createDays() -> [Day] {
        return filterHiddenBookmarks(
            schedules: Array(viewModel.schedules),
            hiddenBookmarks: viewModel.hiddenBookmarks)
        .flatten().ordered()
    }
    
}

