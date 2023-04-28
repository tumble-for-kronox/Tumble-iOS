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
    @State private var eventsByDate: [Date: [Event]] = [:]
    
    @Binding var days: [Day]
    
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            // Set up the calendar view with scrollEnabled set to false
            CalendarViewRepresentable(
                selectedDate: $selectedDate,
                displayedDayEvents: $displayedDayEvents,
                days: $days,
                eventsByDate: $eventsByDate
            )
            .id(eventsByDate) // Update if eventsByDate changes
            .frame(height: 375)
            .onFirstAppear {
                updateDisplayedDayEvents(for: selectedDate)
                eventsByDate = makeCalendarEvents()
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
        .onChange(of: days, perform: { _ in
            updateDisplayedDayEvents(for: Date.now)
            eventsByDate = makeCalendarEvents()
        })
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
    
    private func makeCalendarEvents() -> [Date: [Event]] {
        var dict = [Date: [Event]]()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        for day in days {
            guard day.isValidDay() else { continue }
            for event in day.events {
                if let date = dateFormatterEvent.date(from: event.from) {
                    let normalizedDate = Calendar.current.startOfDay(for: date)
                    if dict[normalizedDate] == nil {
                        dict[normalizedDate] = [event]
                    } else {
                        dict[normalizedDate]?.append(event)
                    }
                }
            }
        }
        return dict
    }
}
