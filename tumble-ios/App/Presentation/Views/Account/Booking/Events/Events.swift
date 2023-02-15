//
//  RegisteredEvents.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 2023-02-15.
//

import SwiftUI

struct Events: View {
    
    let registeredEvents: [Response.AvailableKronoxUserEvent]?
    let unregisteredEvents: [Response.AvailableKronoxUserEvent]?
    let upcomingEvents: [Response.UpcomingKronoxUserEvent]?
    let onTapEventAction: ((String, EventType) -> Void)?
    
    init(registeredEvents: [Response.AvailableKronoxUserEvent]? = nil, unregisteredEvents: [Response.AvailableKronoxUserEvent]? = nil, upcomingEvents: [Response.UpcomingKronoxUserEvent]? = nil, onTapEventAction: ((String, EventType) -> Void)? = nil) {
        self.registeredEvents = registeredEvents
        self.unregisteredEvents = unregisteredEvents
        self.upcomingEvents = upcomingEvents
        self.onTapEventAction = onTapEventAction
    }
    
    var body: some View {
        if let events = unregisteredEvents, let onTapEventAction = onTapEventAction {
            VStack (alignment: .leading) {
                ForEach(events, id: \.id) { event in
                    EventCard(event: event, eventType: .register, onTap: onTapEventAction)
                }
            }
            if events.isEmpty {
                Text("No exams available")
                    .sectionDividerEmpty()
                    .padding(.top, 5)
            }
        }
        
        if let events = registeredEvents, let onTapEventAction = onTapEventAction {
            VStack (alignment: .leading, spacing: 15) {
                ForEach(events, id: \.id) { event in
                    EventCard(event: event, eventType: .unregister, onTap: onTapEventAction)
                }
            }
            if events.isEmpty {
                Text("No exams available")
                    .sectionDividerEmpty()
                    .padding(.top, 5)
            }
        }
        
        if let upcomingEvents = upcomingEvents {
            VStack (alignment: .leading) {
                ForEach(upcomingEvents, id: \.id) { event in
                    UpcomingEventCard(event: event)
                }
            }
            if upcomingEvents.isEmpty {
                Text("No upcoming exams available")
                    .sectionDividerEmpty()
                    .padding(.top, 5)
            }
        }
    }
}

