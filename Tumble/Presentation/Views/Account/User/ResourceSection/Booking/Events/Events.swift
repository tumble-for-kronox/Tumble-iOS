//
//  RegisteredEvents.swift
//  Tumble
//
//  Created by Adis Veletanlic on 2023-02-15.
//

import SwiftUI

struct Events: View {
    let registeredEvents: [NetworkResponse.AvailableKronoxUserEvent]?
    let unregisteredEvents: [NetworkResponse.AvailableKronoxUserEvent]?
    let upcomingEvents: [NetworkResponse.UpcomingKronoxUserEvent]?
    let onTapEventAction: ((String, EventType) -> Void)?
    
    init(
        registeredEvents: [NetworkResponse.AvailableKronoxUserEvent]? = nil,
        unregisteredEvents: [NetworkResponse.AvailableKronoxUserEvent]? = nil,
        upcomingEvents: [NetworkResponse.UpcomingKronoxUserEvent]? = nil,
        onTapEventAction: ((String, EventType) -> Void)? = nil
    ) {
        self.registeredEvents = registeredEvents
        self.unregisteredEvents = unregisteredEvents
        self.upcomingEvents = upcomingEvents
        self.onTapEventAction = onTapEventAction
    }
    
    var body: some View {
        unregisteredEventsView
        registeredEventsView
        upcomingEventsView
    }
    
    var registeredEventsView: some View {
        VStack {
            if let events = registeredEvents, let onTapEventAction = onTapEventAction {
                VStack(alignment: .leading, spacing: 15) {
                    ForEach(events, id: \.id) { event in
                        EventCardButton(event: event, eventType: .unregister, onTap: onTapEventAction)
                    }
                }
                if events.isEmpty {
                    Text(NSLocalizedString("No registered events available", comment: ""))
                        .sectionDividerEmpty()
                        .padding(.top, 5)
                }
            }
        }
    }
    
    var unregisteredEventsView: some View {
        VStack {
            if let events = unregisteredEvents, let onTapEventAction = onTapEventAction {
                VStack(alignment: .leading) {
                    ForEach(events, id: \.id) { event in
                        EventCardButton(event: event, eventType: .register, onTap: onTapEventAction)
                    }
                }
                if events.isEmpty {
                    Text(NSLocalizedString("No unregistered events available", comment: ""))
                        .sectionDividerEmpty()
                        .padding(.top, 5)
                }
            }
        }
    }
    
    var upcomingEventsView: some View {
        VStack {
            if let upcomingEvents = upcomingEvents {
                VStack(alignment: .leading) {
                    ForEach(upcomingEvents, id: \.id) { event in
                        UpcomingEventCardButton(event: event)
                    }
                }
                if upcomingEvents.isEmpty {
                    Text(NSLocalizedString("No upcoming events available", comment: ""))
                        .sectionDividerEmpty()
                        .padding(.top, 5)
                }
            }
        }
    }
}
