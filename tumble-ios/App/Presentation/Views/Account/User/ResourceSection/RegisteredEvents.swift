//
//  RegisteredEvents.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 2023-02-15.
//

import SwiftUI

struct RegisteredEvents: View {
    
    let onClickEvent: (Response.AvailableKronoxUserEvent) -> Void
    @Binding var state: PageState
    let registeredEvents: [Response.AvailableKronoxUserEvent]?
    
    var body: some View {
        VStack {
            switch state {
            case .loading:
                CustomProgressIndicator()
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.top)
            case .loaded:
                if let events = registeredEvents {
                    if !events.isEmpty {
                        ForEach(events) { event in
                            if let eventStart = event.eventStart.convertToHoursAndMinutes(),
                               let eventEnd = event.eventEnd.convertToHoursAndMinutes() {
                                ResourceCard(
                                    timeSpan: "\(event.eventStart.convertToHoursAndMinutes() ?? "")",
                                    type: event.type,
                                    title: event.title,
                                    date: event.eventStart.toDate() ?? "(no date)",
                                    hoursMinutes: "\(eventStart) - \(eventEnd)",
                                    onClick: {
                                        onClickEvent(event)
                                    }
                                )
                            }
                            
                        }
                    } else {
                        Text("No registered events yet")
                            .sectionDividerEmpty()
                    }
                } else {
                    Text("No registered events yet")
                        .sectionDividerEmpty()
                }
            case .error:
                Text("Could not contact the server")
                    .sectionDividerEmpty()
            }
            Spacer()
        }
    }
}
