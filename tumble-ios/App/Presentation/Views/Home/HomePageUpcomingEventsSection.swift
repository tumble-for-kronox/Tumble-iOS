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
        VStack (alignment: .leading) {
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
                HomePageSectionDivider(onTapSeeAll: {
                    AppController.shared.selectedAppTab = .bookmarks
                }, title: "Today's classes", contentCount: parentViewModel.eventsForToday!.count)
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
        .frame(maxHeight: UIScreen.main.bounds.height / 2.75)
    }
}

struct HomePageUpcomingEventsSection_Previews: PreviewProvider {
    static var previews: some View {
        HomePageUpcomingEventsSection(
            parentViewModel: ViewModelFactory.shared.makeViewModelHomePage()
        )
    }
}
