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
    
    @Namespace private var animationNamespace
    
    var body: some View {
        NavigationView {
            VStack(alignment: .center) {
                switch viewModel.status {
                case .loading:
                    CustomProgressIndicator()
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                case .loaded:
                    ZStack (alignment: .bottom) {
                        TabView (selection: $viewModel.defaultViewType) {
                            BookmarkListView(
                                days: viewModel.bookmarkData.days,
                                appController: appController,
                                viewModel: viewModel
                            )
                            .tag(ViewType.list)
                            
                            BookmarkCalendarView(
                                appController: appController,
                                calendarEventsByDate: viewModel.bookmarkData.calendarEventsByDate,
                                days: viewModel.bookmarkData.days
                            )
                            .tag(ViewType.calendar)
                            
                            BookmarkWeekView(
                                scheduleWeeks: viewModel.bookmarkData.weeks,
                                viewModel: viewModel
                            )
                            .tag(ViewType.week)
                        }
                        .tabViewStyle(.page(indexDisplayMode: .never))
                        
                        if viewModel.viewSwitcherVisible {
                            ViewSwitcher(parentViewModel: viewModel)
                                .padding(.bottom, Spacing.medium)
                                .matchedGeometryEffect(id: "viewSwitcher", in: animationNamespace)
                                .transition(.move(edge: .bottom))
                        }
                    }
                case .uninitialized:
                    Info(title: NSLocalizedString("No bookmarks yet", comment: ""), image: "bookmark.slash")
                case .hiddenAll:
                    Info(title: NSLocalizedString("All your bookmarks are hidden", comment: ""), image: "bookmark.slash")
                case .error:
                    Info(title: NSLocalizedString("Something went wrong", comment: ""), image: nil)
                case .empty:
                    Info(title: NSLocalizedString("Your visible schedules do not contain any events", comment: ""), image: "calendar.badge.exclamationmark")
                }
            }
            .background(Color.background)
            .onAppear {
                UIApplication.shared.applicationIconBadgeNumber = 0
            }
            .fullScreenCover(item: $appController.eventSheet) { (eventSheet: EventDetailsSheetModel) in
                EventDetailsSheet(
                    viewModel: viewModel.createViewModelEventSheet(
                        event: eventSheet.event))
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarTitle(NSLocalizedString("Bookmarks", comment: ""))
        }
        .tag(TabbarTabType.bookmarks)
    }
}

