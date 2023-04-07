//
//  HomeAvailable.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 2023-04-04.
//

import SwiftUI

struct HomeAvailable: View {
    
    @Binding var eventsForToday: [WeekEventCardModel]
    @Binding var nextClass: Response.Event?
    @Binding var swipedCards: Int
    @Binding var courseColors: CourseAndColorDict?
    @Binding var todayEventsSectionStatus: GenericPageStatus
    
    var body: some View {
        VStack {
            TodaysEvents(
                courseColors: courseColors,
                eventsForToday: $eventsForToday,
                swipedCards: $swipedCards,
                todayEventsSectionStatus: $todayEventsSectionStatus)
            NextClass(nextClass: nextClass, courseColors: courseColors)
            Spacer()
        }
        .frame(width: getRect().width - 35)
    }
}
