//
//  SchedulePageMainView.swift
//  Tumble
//
//  Created by Adis Veletanlic on 11/21/22.
//

import RealmSwift
import SwiftUI

struct Bookmarks: View {
    @ObservedObject var viewModel: BookmarksViewModel
    @ObservedObject var parentViewModel: ParentViewModel
    @ObservedObject var appController: AppController = .shared
    @ObservedResults(Schedule.self) var schedules
    
    var body: some View {
        VStack(alignment: .center) {
            VStack {
                ViewSwitcher(parentViewModel: viewModel)
                switch viewModel.status {
                case .loading:
                    CustomProgressIndicator()
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                case .loaded:
                    if schedules.isEmpty {
                        Info(title: NSLocalizedString("No bookmarks yet", comment: ""), image: "bookmark.slash")
                    } else if schedules.filter({ $0.toggled }).isEmpty {
                        Info(title: NSLocalizedString("All your bookmarks are hidden", comment: ""), image: "eyeglasses")
                    } else {
                        switch viewModel.defaultViewType {
                        case .list:
                            BookmarkListView(
                                days: viewModel.days,
                                appController: appController
                            )
                        case .calendar:
                            BookmarkCalendarView(
                                appController: appController,
                                days: viewModel.days
                            )
                        }
                    }
                case .uninitialized:
                    Info(title: NSLocalizedString("No bookmarks yet", comment: ""), image: "bookmark.slash")
                case .hiddenAll:
                    Info(title: NSLocalizedString("All your bookmarks are hidden", comment: ""), image: "bookmark.slash")
                case .error:
                    Info(title: NSLocalizedString("Something went wrong", comment: ""), image: nil)
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
}
