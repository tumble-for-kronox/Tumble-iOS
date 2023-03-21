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
    
    fileprivate func onTapDetail(event: Response.Event, color: Color) -> Void {
        appController.eventSheet = EventDetailsSheetModel(event: event, color: color)
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
    fileprivate var eventsByDate: [String: [Response.Event]] {
            var dict = [String: [Response.Event]]()
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            
            for day in days {
                for event in day.events {
                    if let date = eventDateFormatter.date(from: event.from) {
                        let dateString = dateFormatter.string(from: date)
                        if dict[dateString] == nil {
                            dict[dateString] = [event]
                        } else {
                            dict[dateString]?.append(event)
                        }
                    }
                }
            }
            return dict
        }

    
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
        calendar.scrollDirection = .vertical
        calendar.scope = .month
        calendar.clipsToBounds = false
        calendar.firstWeekday = 2
        
        return calendar
    }
    
    func updateUIView(_ uiView: FSCalendar, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, FSCalendarDelegate, FSCalendarDataSource, FSCalendarDelegateAppearance {
        var parent: CalendarViewRepresentable
        
        init(_ parent: CalendarViewRepresentable) {
            self.parent = parent
            super.init()
        }
        
        // Set cell indicators on individual calendar cells,
        // to display amount of events for a single date before pressing it
        func calendar(
            _ calendar: FSCalendar,
            willDisplay cell: FSCalendarCell,
            for date: Date, at monthPosition: FSCalendarMonthPosition) {
                let filteredEvents = parent.eventsByDate[parent.dateFormatter.string(from: date)] ?? []
                cell.eventIndicator.isHidden = false
                cell.eventIndicator.color = UIColor(named: "PrimaryColor")
                cell.eventIndicator.numberOfEvents = filteredEvents.count
        }
        
        // Handle the click of a date cell
        func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
            parent.selectedDate = date
            parent.displayedDayEvents = parent.eventsByDate[parent.dateFormatter.string(from: date)] ?? []
            for cell in parent.calendar.visibleCells() {
                if let cellDate = parent.calendar.date(for: cell) {
                    let filteredEvents = parent.eventsByDate[parent.dateFormatter.string(from: cellDate)] ?? []
                    cell.eventIndicator.isHidden = false
                    cell.eventIndicator.color = UIColor(named: "PrimaryColor")
                    cell.eventIndicator.numberOfEvents = filteredEvents.count
                }
            }
        }
        
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

