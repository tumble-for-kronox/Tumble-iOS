//
//  CalendarView.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 2023-03-18.
//

import Foundation
import UIKit
import SwiftUI
import FSCalendar

struct BookmarkCalendarView: View {
    
    @Binding var days: [DayUiModel]
    let courseColors: CourseAndColorDict
    @ObservedObject var appController: AppController
    
    @State private var displayedDayEvents: [Response.Event] = [Response.Event]()
    @State private var selectedDate: Date = Date()

    
    var body: some View {
        ScrollView (showsIndicators: false) {
            // Set up the calendar view with scrollEnabled set to false
            CalendarViewRepresentable(
                selectedDate: $selectedDate,
                displayedDayEvents: $displayedDayEvents,
                days: days,
                courseColors: courseColors
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
                            let color = courseColors[event.course.id] != nil ?
                            courseColors[event.course.id]!.toColor() : .white
                            BookmarkCalendarDetail(
                                onTapDetail: onTapDetail,
                                event: event,
                                color: color
                            )
                        }
                    }
                    .padding(.top, 20)
                }
            }
        }
    }
    
    private func onTapDetail(event: Response.Event, color: Color) -> Void {
        appController.eventSheet = EventDetailsSheetModel(event: event, color: color)
    }
    
    private func updateDisplayedDayEvents(for date: Date) {
        displayedDayEvents = days.filter { day in
            let dayDate = isoDateFormatterFract.date(from: day.isoString) ?? Date()
            return Calendar.current.isDate(dayDate, inSameDayAs: date)
        }.flatMap { $0.events }
    }

}


