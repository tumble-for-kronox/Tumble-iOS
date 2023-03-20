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
        ScrollView (showsIndicators: false) {
            switch state {
            case .loading:
                CustomProgressIndicator()
                    .frame(maxWidth: .infinity, alignment: .center)
            case .loaded:
                if let events = registeredEvents {
                    if !events.isEmpty {
                        ForEach(events) { event in
                            ResourceCard(
                                timeSpan: "\(event.eventStart.convertToHourMinute() ?? "")",
                                title: event.title)
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
        }
        .frame(maxHeight: UIScreen.main.bounds.height / 4)
    }
}
