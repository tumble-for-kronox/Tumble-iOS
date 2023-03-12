//
//  ExamBookings.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 2023-02-14.
//

import SwiftUI



struct EventBookings: View {
    
    @ObservedObject var viewModel: AccountPageViewModel
    
    var body: some View {
        GeometryReader { geo in
            ScrollView (.vertical) {
                switch viewModel.eventBookingPageState {
                case .loading:
                    CustomProgressIndicator()
                        .frame(width: geo.size.width)
                        .frame(minHeight: geo.size.height)
                case .loaded:
                    SectionDivider(title: "Registered", image: "person.crop.circle.badge.checkmark", content: {
                        Events(registeredEvents: viewModel.completeUserEvent?.registeredEvents, onTapEventAction: { eventId, eventType in
                            onTapEventAction(eventId: eventId, eventType: eventType)
                        })
                    })
                    SectionDivider(title: "Unregistered", image: "person.crop.circle.badge.xmark", content: {
                        Events(unregisteredEvents: viewModel.completeUserEvent?.unregisteredEvents, onTapEventAction: { eventId, eventType in
                            onTapEventAction(eventId: eventId, eventType: eventType)
                        })
                    })
                    SectionDivider(title: "Upcoming", image: "person.crop.circle.badge.clock", content: {
                        Events(upcomingEvents: viewModel.completeUserEvent?.upcomingEvents)
                    })
                case .error:
                    Info(title: "Could not contact the server", image: "wifi.exclamationmark")
                        .frame(width: geo.size.width)
                        .frame(minHeight: geo.size.height)
                }
            }
            .frame(maxHeight: .infinity, alignment: .center)
        }
        .onAppear {
            viewModel.getUserEventsForPage()
        }
        .onDisappear {
            viewModel.getUserEventsForSection()
        }
    }
    
    
    func onTapEventAction(eventId: String, eventType: EventType) -> Void {
        switch eventType {
        case .register:
            viewModel.registerForEvent(eventId: eventId)
        case .unregister:
            viewModel.unregisterForEvent(eventId: eventId)
        }
    }
    
}
