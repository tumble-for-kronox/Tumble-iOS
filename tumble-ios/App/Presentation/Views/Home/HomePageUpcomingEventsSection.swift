//
//  HomePageUpcomingEventsSection.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 2023-03-19.
//

import SwiftUI

struct HomePageUpcomingEventsSection: View {
    
    @ObservedObject var parentViewModel: HomePageViewModel
    
    var body: some View {
        // List of events that are for the coming week
        switch parentViewModel.bookmarkedEventsSectionStatus {
        case .loading:
            Spacer()
            HStack {
                Spacer()
                CustomProgressIndicator()
                Spacer()
            }
            Spacer()
        case .loaded:
            HomePageSectionDivider(eventCount: parentViewModel.eventsForToday!.count)
            if !parentViewModel.eventsForToday!.isEmpty {
                ScrollView {
                    LazyVStack {
                        ForEach(parentViewModel.eventsForToday!, id: \.self) { event in
                            HomePageEventButton(
                                onTapEvent: {event in},
                                event: event,
                                color: parentViewModel.courseColors![event.course.id] != nil ?
                                parentViewModel.courseColors![event.course.id]!.toColor() : .white
                            )
                        }
                    }
                }.frame(maxHeight: UIScreen.main.bounds.height / 3)
            } else {
                Info(title: "No events for today", image: "sparkles")
                    .frame(maxHeight: UIScreen.main.bounds.height / 3)
            }
        case .error:
            Text("Error")
        }
    }
}

struct HomePageUpcomingEventsSection_Previews: PreviewProvider {
    static var previews: some View {
        HomePageUpcomingEventsSection(
            parentViewModel: ViewModelFactory.shared.makeViewModelHomePage()
        )
    }
}
