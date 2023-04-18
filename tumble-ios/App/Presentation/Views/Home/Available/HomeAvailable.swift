//
//  HomeAvailable.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 2023-04-04.
//

import SwiftUI

struct HomeAvailable: View {
    
    @Binding var eventsForToday: [WeekEventCardModel]
    @Binding var nextClass: Event?
    @Binding var swipedCards: Int
    
    var body: some View {
        VStack {
            TodaysEvents(
                eventsForToday: $eventsForToday,
                swipedCards: $swipedCards)
            NextClass(nextClass: nextClass)
            Spacer()
        }
        .frame(width: getRect().width - 35)
    }
}
