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
        VStack {
            CalendarViewRepresentable(
                selectedDate: $selectedDate,
                displayEvents: $displayEvents,
                displayedDayEvents: $displayedDayEvents,
                days: days, courseColors: courseColors
            )
            .ignoresSafeArea(.all, edges: .top)
            Divider()
            ScrollView {
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
                            Button(action: {
                                // Open sheet
                            }, label: {
                                BookmarkCalendarDetail(
                                    onTapDetail: onTapDetail,
                                    event: event,
                                    color: courseColors[event.course.id] != nil ?
                                                       courseColors[event.course.id]!.toColor() : .white
                                )
                            })
                        }
                    }
                    .padding(.top, 20)
                }
            }
            .background(Color.background)
            .frame(maxWidth: .infinity, maxHeight: 150)
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
    private let dateFormatter = DateFormatter()
    
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
        calendar.appearance.headerTitleFont = UIFont(descriptor: UIFontDescriptor.preferredFontDescriptor(withTextStyle: .largeTitle), size: 30)
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
        }
        
        // Set cell indicators on individual calendar cells, to display amount of events for a single date before pressing it
        func calendar(_ calendar: FSCalendar, willDisplay cell: FSCalendarCell, for date: Date, at monthPosition: FSCalendarMonthPosition) {
            let filteredEvents = filterEventList(date: date)
            cell.eventIndicator.isHidden = false
            cell.eventIndicator.color = UIColor(named: "PrimaryColor")
            cell.eventIndicator.numberOfEvents = filteredEvents.count
        }
        
        
        // Handle the click of a date cell
        func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
            parent.selectedDate = date
            parent.displayedDayEvents = filterEventList(date: date)
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
        
        func filterEventList(date: Date) -> [Response.Event] {
            parent.dateFormatter.dateFormat = "yyyy-MM-dd"
            let dateString = parent.dateFormatter.string(from: date)
            // Create a second DateFormatter with the correct format for the event.from string
            let filteredEvents = parent.days.flatMap { dayUiModel in
                dayUiModel.events.filter { event in
                    // Convert the event.from string to a Date object using the second DateFormatter
                    guard let eventDate = eventDateFormatter.date(from: event.from) else {
                        return false // Return false if the event.from string cannot be converted to a Date
                    }
                    
                    // Compare the eventDate with the selected date
                    let eventDateString = parent.dateFormatter.string(from: eventDate)
                    return eventDateString == dateString
                }
            }
            return filteredEvents
        }
    }
}

