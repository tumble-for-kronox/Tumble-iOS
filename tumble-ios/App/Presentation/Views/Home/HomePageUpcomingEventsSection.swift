//
//  HomePageUpcomingEventsSection.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 2023-03-19.
//

import SwiftUI

struct HomePageUpcomingEventsSection: View {
    
    @ObservedObject var parentViewModel: HomeViewModel
    
    var body: some View {
        // List of events that are for the coming week
        VStack (alignment: .leading) {
            HomePageSectionDivider(onTapSeeAll: {
                AppController.shared.selectedAppTab = .bookmarks
            }, title: "Today's classes", contentCount: parentViewModel.eventsForToday?.count ?? 0)
            switch parentViewModel.bookmarkedEventsSectionStatus {
            case .loading:
                VStack {
                    CustomProgressIndicator()
                }
                .frame(
                    maxWidth: .infinity,
                    maxHeight: .infinity,
                    alignment: .center
                )
            case .loaded:
                if !parentViewModel.eventsForToday!.isEmpty {
                    ScrollView (showsIndicators: false) {
                        LazyVStack {
                            ForEach(parentViewModel.eventsForToday!, id: \.self) { event in
                                let color = parentViewModel.courseColors![event.course.id]?.toColor() ?? .white
                                HomePageEventButton(
                                    onTapEvent: onTapEvent,
                                    event: event,
                                    color: color
                                )
                            }
                        }
                    }
                } else {
                    Text("No classes for today")
                        .font(.system(size: 18))
                        .foregroundColor(.onBackground)
                    Spacer()
                }
            case .error:
                Text("Error")
            }
        }
        .frame(minHeight: UIScreen.main.bounds.height / 5)
    }
    
    func onTapEvent(event: Response.Event, color: Color) -> Void {
        parentViewModel.eventSheet = EventDetailsSheetModel(event: event, color: color)
    }
}

struct HomePageUpcomingEventsSection_Previews: PreviewProvider {
    static var previews: some View {
        HomePageUpcomingEventsSection(
            parentViewModel: ViewModelFactory.shared.makeViewModelHome()
        )
    }
}
