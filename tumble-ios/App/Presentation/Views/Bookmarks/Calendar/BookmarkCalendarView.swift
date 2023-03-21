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
    
    let days: [DayUiModel]
    let courseColors: CourseAndColorDict
    @ObservedObject var appController: AppController
    
    @State private var displayEvents: Bool = false
    @State private var displayedDayEvents: [Response.Event] = [Response.Event]()
    @State private var selectedDate: Date = Date()
    
    var body: some View {
        ScrollView (showsIndicators: false) {
            // Set up the calendar view with scrollEnabled set to false
            CalendarViewRepresentable(
                selectedDate: $selectedDate,
                displayEvents: $displayEvents,
                displayedDayEvents: $displayedDayEvents,
                days: days,
                courseColors: courseColors
            )
            .frame(height: 350)
            .onAppear {
                updateDisplayedDayEvents(for: selectedDate)
            }
            
            // Add other views below the calendar view inside a VStack
            VStack {
                if displayedDayEvents.isEmpty {
                    HStack {
                        Text("No events for this date")
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
            let dayDate = inDateFormatter.date(from: day.isoString) ?? Date()
            return Calendar.current.isDate(dayDate, inSameDayAs: date)
        }.flatMap { $0.events }
    }

}

struct CalendarViewRepresentable: UIViewRepresentable {
    typealias UIViewType = FSCalendar
    
    fileprivate var calendar = FSCalendar()
    @Binding var selectedDate: Date
    @Binding var displayEvents: Bool
    @Binding var displayedDayEvents: [Response.Event]
    let days: [DayUiModel]
    let courseColors: CourseAndColorDict
    
    fileprivate lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
    
    fileprivate lazy var eventsByDate: [Date: [Response.Event]] = {
        var dict = [Date: [Response.Event]]()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        for day in days {
            for event in day.events {
                if let date = eventDateFormatter.date(from: event.from) {
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
    }()


    
    func makeUIView(context: Context) -> FSCalendar {
        calendar.delegate = context.coordinator
        calendar.dataSource = context.coordinator
        
        calendar.locale = Locale(identifier: "en")
        calendar.appearance.weekdayTextColor = UIColor(named: "PrimaryColor")
        calendar.appearance.titleDefaultColor = UIColor(named: "OnBackground")
        calendar.appearance.selectionColor = UIColor(named: "PrimaryColor")
        calendar.appearance.titleTodayColor = UIColor(named: "OnPrimary")
        calendar.appearance.todayColor = UIColor(named: "PrimaryColor")?.withAlphaComponent(0.5)
        calendar.appearance.titleFont = .boldSystemFont(ofSize: 20)
        calendar.appearance.headerTitleFont = UIFont(
            descriptor: UIFontDescriptor.preferredFontDescriptor(withTextStyle: .largeTitle), size: 30)
        calendar.appearance.headerMinimumDissolvedAlpha = 0.12
        calendar.appearance.headerTitleFont = .systemFont(ofSize: 30, weight: .black)
        calendar.appearance.headerTitleColor = UIColor(named: "OnBackground")
        calendar.appearance.headerDateFormat = "MMMM"
        calendar.appearance.eventDefaultColor = UIColor(named: "PrimaryColor")
        calendar.appearance.eventSelectionColor = UIColor(named: "PrimaryColor")
        calendar.scrollDirection = .vertical
        calendar.scope = .month
        calendar.clipsToBounds = false
        calendar.firstWeekday = 2
        
        return calendar
    }
    
    func updateUIView(_ uiView: FSCalendar, context: Context) {
            uiView.scope = .month
            uiView.locale = Locale(identifier: "en")
            uiView.firstWeekday = 2
            uiView.appearance.weekdayTextColor = UIColor(named: "PrimaryColor")
            uiView.appearance.titleDefaultColor = UIColor(named: "OnBackground")
            uiView.appearance.selectionColor = UIColor(named: "PrimaryColor")
            uiView.appearance.titleTodayColor = UIColor(named: "OnPrimary")
            uiView.appearance.todayColor = UIColor(named: "PrimaryColor")?.withAlphaComponent(0.5)
            uiView.appearance.titleFont = .boldSystemFont(ofSize: 20)
            uiView.appearance.headerTitleFont = UIFont(
                descriptor: UIFontDescriptor.preferredFontDescriptor(withTextStyle: .largeTitle), size: 30)
            uiView.appearance.headerMinimumDissolvedAlpha = 0.12
            uiView.appearance.headerTitleFont = .systemFont(ofSize: 30, weight: .black)
            uiView.appearance.headerTitleColor = UIColor(named: "OnBackground")
            uiView.appearance.headerDateFormat = "MMMM"
        
            uiView.appearance.eventDefaultColor = UIColor(named: "PrimaryColor")
            uiView.appearance.eventSelectionColor = UIColor(named: "PrimaryColor")
        }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, FSCalendarDelegate, FSCalendarDataSource, FSCalendarDelegateAppearance {
        
        var parent: CalendarViewRepresentable
        fileprivate var displayedDayEventsByDate: [Date: [Response.Event]] = [:]
        
        init(_ parent: CalendarViewRepresentable) {
            self.parent = parent
        }
        
        /// Set cell indicators on individual calendar cells,
        /// to display amount of events for a single date before pressing it
        func calendar(
                _ calendar: FSCalendar,
                willDisplay cell: FSCalendarCell,
                for date: Date, at monthPosition: FSCalendarMonthPosition) {
                    let filteredEvents = displayedDayEventsByDate[date] ?? []
                    cell.eventIndicator.isHidden = false
                    cell.eventIndicator.numberOfEvents = filteredEvents.count
            }
        
        /// Handle the click of a date cell
        func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
            parent.selectedDate = date
            parent.displayedDayEvents = displayedDayEventsByDate[date] ?? []
            
            for cell in parent.calendar.visibleCells() {
                if let cellDate = parent.calendar.date(for: cell) {
                    let filteredEvents = displayedDayEventsByDate[cellDate] ?? []
                    cell.eventIndicator.isHidden = false
                    cell.eventIndicator.numberOfEvents = filteredEvents.count
                }
            }
        }

        /// Calculate number of events for a specific cell
        func calendar(_ calendar: FSCalendar, numberOfEventsFor date: Date) -> Int {
            let filteredEvents = parent.eventsByDate[date] ?? []
            displayedDayEventsByDate[date] = filteredEvents
            return filteredEvents.count
        }

        
        /// All date cells are clickable
        func calendar(_ calendar: FSCalendar, shouldSelect date: Date, at monthPosition: FSCalendarMonthPosition) -> Bool {
            return true
        }
        
        func maximumDate(for calendar: FSCalendar) -> Date {
            let sixMonths = DateComponents(month: 6)
            return Calendar.current.date(byAdding: sixMonths, to: Date()) ?? Date()
        }

        
        func minimumDate(for calendar: FSCalendar) -> Date {
            Date.now
        }
    }
}

