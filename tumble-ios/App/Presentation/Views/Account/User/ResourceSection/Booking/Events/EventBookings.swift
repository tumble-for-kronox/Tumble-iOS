//
//  ExamBookings.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 2023-02-14.
//

import SwiftUI

enum PageState {
    case loading
    case loaded
    case error
}

struct EventBookings: View {
    
    @EnvironmentObject var user: UserController
    @ObservedObject var viewModel: AccountPageViewModel
    @State private var state: PageState = .loading
    
    var body: some View {
        GeometryReader { geo in
            ScrollView (.vertical) {
                switch state {
                case .loading:
                    CustomProgressIndicator()
                        .frame(width: geo.size.width)
                        .frame(minHeight: geo.size.height)
                case .loaded:
                    SectionDivider(title: "Registered", image: "person.crop.circle.badge.checkmark", content: {
                        Events(registeredEvents: user.completeUserEvent?.registeredEvents, onTapEventAction: { eventId, eventType in
                            onTapEventAction(eventId: eventId, eventType: eventType, completion: getUserEvents)
                        })
                    })
                    SectionDivider(title: "Unregistered", image: "person.crop.circle.badge.xmark", content: {
                        Events(unregisteredEvents: user.completeUserEvent?.unregisteredEvents, onTapEventAction: { eventId, eventType in
                            onTapEventAction(eventId: eventId, eventType: eventType, completion: getUserEvents)
                        })
                    })
                    SectionDivider(title: "Upcoming", image: "person.crop.circle.badge.clock", content: {
                        Events(upcomingEvents: user.completeUserEvent?.upcomingEvents)
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
            getUserEvents()
        }
    }
 
    func getUserEvents() -> Void {
        user.getUserEvents(completion: loadUserEvents)
    }
    
    func loadUserEvents(success: Bool) -> Void {
        DispatchQueue.main.async {
            if success {
                self.state = .loaded
            } else {
                self.state = .error
            }
        }
    }
    
    func onTapEventAction(eventId: String, eventType: EventType, completion: @escaping () -> Void) -> Void {
        self.state = .loading
        DispatchQueue.main.async {
            switch eventType {
            case .register:
                self.user.registerForEvent(with: eventId, completion: { [self] result in
                    switch result {
                    case .success(_):
                        completion()
                    case .failure(let failure):
                        AppLogger.shared.info("Error when registering for event -> \(failure.localizedDescription)")
                        self.state = .error
                    }
                })
            case .unregister:
                self.user.unregisterForEvent(with: eventId, completion: { [self] result in
                    switch result {
                    case .success(_):
                        completion()
                    case .failure(let failure):
                        AppLogger.shared.info("Error when unregistering for event -> \(failure.localizedDescription)")
                        self.state = .error
                    }
                })
            }
        }
    }
    
}
