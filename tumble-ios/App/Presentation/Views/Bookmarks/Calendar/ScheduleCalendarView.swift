//
//  ScheduleListView.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 2023-01-25.
//

import SwiftUI
import ElegantCalendar

struct ScheduleCalendarView: View {
    
    @ObservedObject var calendarManager = MonthlyCalendarManager(
        configuration: CalendarConfiguration(
            startDate: Date.now,
            endDate: Calendar.current.date(byAdding: .year, value: 1, to: Date.now)!))
    
    var body: some View {
        VStack {
            MonthlyCalendarView(calendarManager: calendarManager)
                .theme(CalendarTheme(primary: Color("PrimaryColor"), titleColor: Color("PrimaryColor"), textColor: Color("SecondaryColor"), todayTextColor: Color("OnPrimary"), todayBackgroundColor: Color("PrimaryColor")))
        }
        
    }
}

struct ScheduleListView_Previews: PreviewProvider {
    static var previews: some View {
        ScheduleCalendarView()
    }
}
