//
//  RegisteredEvents.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 2023-02-15.
//

import SwiftUI

struct RegisteredEvents: View {
    
    let registeredEvents: [Response.AvailableKronoxUserEvent]?
    
    var body: some View {
        if let registeredEvents = registeredEvents {
            VStack (alignment: .leading) {
                ForEach(registeredEvents, id: \.id) { event in
                    VStack (alignment: .leading) {
                        Text(event.title)
                        Text("\(event.eventStart.convertToHourMinute() ?? "") - \(event.eventEnd.convertToHourMinute() ?? "")")
                    }
                }
            }
        }
    }
}

