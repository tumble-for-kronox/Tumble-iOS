//
//  TodaysEvents.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 2023-04-04.
//

import SwiftUI

struct TodaysEvents: View {
    
    @Binding var eventsForToday: [WeekEventCardModel]
    @Binding var swipedCards: Int
    
    var body: some View {
        VStack (alignment: .leading) {
            Text(NSLocalizedString("Today's events", comment: ""))
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.onBackground)
            VStack {
                if !eventsForToday.isEmpty {
                    TodaysEventsCarousel(
                        eventsForToday: $eventsForToday,
                        swipedCards: $swipedCards
                    )
                } else {
                    Text(NSLocalizedString("No events for today", comment: ""))
                        .font(.system(size: 16))
                        .foregroundColor(.onBackground)
                }
            }
            .frame(minHeight: 100, alignment: .top)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
