//
//  ExamBookings.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 2023-02-14.
//

import SwiftUI



struct EventBookings: View {
    
    @ObservedObject var viewModel: ResourceViewModel
    
    let getUserEventsForSection: () -> Void
    
    var body: some View {
        GeometryReader { geo in
            ScrollView (.vertical, showsIndicators: false) {
                switch viewModel.eventBookingPageState {
                case .loading:
                    CustomProgressIndicator()
                        .frame(width: geo.size.width)
                        .frame(minHeight: geo.size.height)
                case .loaded:
                    SectionDivider(title: "Registered", image: "person.crop.circle.badge.checkmark", content: {
                        if (viewModel.completeUserEvent?.registeredEvents) != nil {
                            Events(registeredEvents: viewModel.completeUserEvent?.registeredEvents, onTapEventAction: { eventId, eventType in
                                onTapEventAction(eventId: eventId, eventType: eventType)
                            })
                        } else {
                            Text("No registered events available")
                                .sectionDividerEmpty()
                                .padding(.top, 5)
                        }
                    })
                    SectionDivider(title: "Unregistered", image: "person.crop.circle.badge.xmark", content: {
                        if (viewModel.completeUserEvent?.unregisteredEvents != nil) {
                            Events(unregisteredEvents: viewModel.completeUserEvent?.unregisteredEvents, onTapEventAction: { eventId, eventType in
                                onTapEventAction(eventId: eventId, eventType: eventType)
                            })
                        } else {
                            Text("No unregistered events available")
                                .sectionDividerEmpty()
                                .padding(.top, 5)
                        }
                    })
                    SectionDivider(title: "Upcoming", image: "person.crop.circle.badge.clock", content: {
                        if (viewModel.completeUserEvent?.upcomingEvents != nil) {
                            Events(upcomingEvents: viewModel.completeUserEvent?.upcomingEvents)
                        } else {
                            Text("No upcoming events available")
                                .sectionDividerEmpty()
                                .padding(.top, 5)
                        }
                    })
                case .error:
                    Info(title: "Could not contact the server", image: nil)
                        .frame(width: geo.size.width)
                        .frame(minHeight: geo.size.height)
                }
            }
            .background(Color(UIColor.systemBackground))
            .frame(maxHeight: .infinity, alignment: .center)
        }
        .onAppear {
            viewModel.getUserEventsForPage()
        }
        .onDisappear {
            getUserEventsForSection()
        }
    }
    
    
    func onTapEventAction(eventId: String, eventType: EventType) -> Void {
        switch eventType {
        case .register:
            viewModel.registerForEvent(eventId: eventId, completion: { result in
                switch result {
                case .success:
                    viewModel.getUserEventsForPage()
                case .failure:
                    DispatchQueue.main.async {
                        viewModel.eventBookingPageState = .error
                    }
                }
            })
        case .unregister:
            viewModel.unregisterForEvent(eventId: eventId, completion: { result in
                switch result {
                case .success:
                    viewModel.getUserEventsForPage()
                case .failure:
                    DispatchQueue.main.async {
                        viewModel.eventBookingPageState = .error
                    }
                }
            })
        }
    }
    
}
