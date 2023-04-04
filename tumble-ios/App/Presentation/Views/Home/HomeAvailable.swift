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
            .padding(.horizontal, 15)
            VStack (alignment: .leading) {
                HStack {
                    if let nextClass = nextClass {
                        Text(nextClass.from.formatDate() ?? "")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.gray)
                    }
                    Spacer()
                    Text(NSLocalizedString("Next class", comment: ""))
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.onBackground)
                }
                if let courseColors = courseColors, let nextClass = nextClass {
                    if let color = courseColors[(nextClass.course.id)] {
                        CompactEventButtonLabel(event: nextClass, color: color.toColor())
                            .frame(maxWidth: .infinity, minHeight: 100, maxHeight: 100, alignment: .center)
                            .background(color.toColor().opacity(0.2))
                            .cornerRadius(20)
                            .padding(.bottom, 10)
                    }
                } else {
                    Text(NSLocalizedString("No upcoming class", comment: ""))
                        .font(.system(size: 16))
                        .foregroundColor(.onBackground)
                }
            }
            .frame(minHeight: 100)
            .padding(.top, 20)
            .padding(.horizontal, 15)
            Spacer()
        }
    }
}
