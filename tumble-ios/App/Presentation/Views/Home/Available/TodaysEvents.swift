//
//  TodaysEvents.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 2023-04-04.
//

import SwiftUI

struct TodaysEvents: View {
    
    let courseColors: CourseAndColorDict?
    @Binding var eventsForToday: [WeekEventCardModel]
    @Binding var swipedCards: Int
    @Binding var todayEventsSectionStatus: GenericPageStatus
    
    var body: some View {
        VStack (alignment: .leading) {
            Text(NSLocalizedString("Today's events", comment: ""))
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.onBackground)
            VStack {
                if let courseColors = courseColors {
                    if !eventsForToday.isEmpty {
                        TodaysEventsCarousel(
                            courseColors: courseColors,
                            eventsForToday: $eventsForToday,
                            swipedCards: $swipedCards,
                            bookmarkedEventsSectionStatus: $todayEventsSectionStatus
                        )
                    } else {
                        Text(NSLocalizedString("No events for today", comment: ""))
                            .font(.system(size: 16))
                            .foregroundColor(.onBackground)
                    }
                }
            }
            .frame(minHeight: 100, alignment: .top)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
