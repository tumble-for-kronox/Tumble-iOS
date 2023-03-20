//
//  HomePageNewsSection.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 2023-03-20.
//

import SwiftUI

struct HomePageNewsSection: View {
    
    @ObservedObject var parentViewModel: HomePageViewModel
    
    var body: some View {
        switch parentViewModel.newsSectionStatus {
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
                // Open sheet with all news items
            }, title: "News", contentCount: parentViewModel.news.count)
            if !parentViewModel.news.isEmpty {
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
                Text("No news for today")
                    .font(.system(size: 18))
                    .foregroundColor(.onBackground)
            }
        case .error:
            Text("Error")
        }
    }
}

struct HomePageNewsSection_Previews: PreviewProvider {
    static var previews: some View {
        HomePageNewsSection(
            parentViewModel: ViewModelFactory.shared.makeViewModelHomePage()
        )
    }
}
