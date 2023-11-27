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
    
    @State private var selectedDateEvents: [Event] = .init()
    @State private var selectedDate: Date = .init()
    var calendarEventsByDate: [Date: [Event]]
    var days: [Day]
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            Spacer()
                .frame(height: 60)
            CalendarViewRepresentable(
                selectedDate: $selectedDate,
                selectedDateEvents: $selectedDateEvents,
                calendarEventsByDate: calendarEventsByDate
            )
            .id(days)
            .onChange(of: days, perform: { _ in
                // Update selected date to be date now
                selectedDate = Date.now
                updateDisplayedDayEvents(for: selectedDate)
            })
            .frame(height: 375)
            
            // Add other views below the calendar view inside a VStack
            VStack {
                if selectedDateEvents.isEmpty {
                    HStack {
                        Text(NSLocalizedString("No events for this date", comment: ""))
                            .foregroundColor(.onBackground)
                            .font(.system(size: 20, weight: .semibold))
                        Spacer()
                    }
                    .padding([.top, .leading], 15)
                } else {
                    VStack {
                        ForEach(selectedDateEvents.sorted(), id: \.self) { event in
                            BookmarkCalendarDetail(
                                onTapDetail: onTapDetail,
                                event: event
                            )
                        }
                    }
                    .padding(.vertical, 20)
                }
            }
        }
        .onFirstAppear {
            updateDisplayedDayEvents(for: selectedDate)
        }
    }
    
    private func onTapDetail(event: Event) {
        appController.eventSheet = EventDetailsSheetModel(event: event)
    }
    
    
    private func updateDisplayedDayEvents(for date: Date) {
        selectedDateEvents = days.filter { day in
            let dayDate = isoDateFormatterFract.date(from: day.isoString) ?? Date()
            return Calendar.current.isDate(dayDate, inSameDayAs: date) && day.isValidDay()
        }.flatMap { $0.events }.removeDuplicates()
    }
    
}
