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
                                    date: event.eventStart.toDate() ?? NSLocalizedString("(no date)", comment: ""),
                                    hoursMinutes: "\(eventStart) - \(eventEnd)",
                                    onClick: {
                                        onClickEvent(event)
                                    }
                                )
                            }
                            
                        }
                    } else {
                        Text(NSLocalizedString("No registered events yet", comment: ""))
                            .sectionDividerEmpty()
                    }
                } else {
                    Text(NSLocalizedString("No registered events yet", comment: ""))
                        .sectionDividerEmpty()
                }
            case .error:
                Text(NSLocalizedString("Could not contact the server", comment: ""))
                    .sectionDividerEmpty()
            }
            Spacer()
        }
        .frame(minHeight: 100)
    }
}
