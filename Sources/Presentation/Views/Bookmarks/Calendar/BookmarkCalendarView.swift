//
//  CalendarView.swift
//  Tumble
//
//  Created by Adis Veletanlic on 2023-03-18.
//

import Foundation
import FSCalendar
import SwiftUI

struct BookmarkCalendarView: View {
    @ObservedObject var appController: AppController
    
    @State private var displayedDayEvents: [Event] = .init()
    @State private var selectedDate: Date = .init()
    
    let days: [Day]
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            // Set up the calendar view with scrollEnabled set to false
            CalendarViewRepresentable(
                selectedDate: $selectedDate,
                displayedDayEvents: $displayedDayEvents,
                days: days.filter { $0.isValidDay() } // Only display valid dates
            )
            .frame(height: 400)
            .onAppear {
                updateDisplayedDayEvents(for: selectedDate)
            }
            
            // Add other views below the calendar view inside a VStack
            VStack {
                if displayedDayEvents.isEmpty {
                    HStack {
                        Text(NSLocalizedString("No events for this date", comment: ""))
                            .foregroundColor(.onBackground)
                            .font(.system(size: 20, weight: .semibold))
                        Spacer()
                    }
                    .padding([.top, .leading], 15)
                } else {
                    VStack {
                        ForEach(displayedDayEvents.sorted(), id: \.self) { event in
                            BookmarkCalendarDetail(
                                onTapDetail: onTapDetail,
                                event: event
                            )
                        }
                    }
                    .padding(.top, 20)
                }
            }
        }
        .id(days)
    }
    
    private func onTapDetail(event: Event) {
        appController.eventSheet = EventDetailsSheetModel(event: event)
    }
    
    private func updateDisplayedDayEvents(for date: Date) {
        displayedDayEvents = days.filter { day in
            let dayDate = isoDateFormatterFract.date(from: day.isoString) ?? Date()
            return Calendar.current.isDate(dayDate, inSameDayAs: date) && day.isValidDay()
        }.flatMap { $0.events }.removeDuplicates()
    }
}
