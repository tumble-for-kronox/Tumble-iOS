//
//  RegisteredEvents.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 2023-02-15.
//

import SwiftUI

struct RegisteredEvents: View {
    
    @Binding var state: PageState
    let registeredEvents: [Response.AvailableKronoxUserEvent]?
    
    var body: some View {
        switch state {
        case .loading:
            CustomProgressIndicator()
                .frame(maxWidth: .infinity, alignment: .center)
        case .loaded:
            VStack {
                if let events = registeredEvents {
                    if !events.isEmpty {
                        ForEach(events) { event in
                            ResourceCard(timeSpan: "\(event.eventStart.convertToHourMinute() ?? "") - \(event.eventEnd.convertToHourMinute() ?? "")", title: event.title)
                        }
                    } else {
                        Text("No registered exams yet")
                            .sectionDividerEmpty()
                    }
                } else {
                    Text("No registered exams yet")
                        .sectionDividerEmpty()
                }
            }
        case .error:
            Text("Could not contact the server")
                .sectionDividerEmpty()
        }
    }
}
