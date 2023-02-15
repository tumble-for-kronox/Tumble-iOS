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
    
    @EnvironmentObject var user: User
    @ObservedObject var viewModel: AccountPage.AccountPageViewModel
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
                        Events(registeredEvents: viewModel.completeUserEvent?.registeredEvents, onTapEventAction: { eventId, eventType in
                            onTapEventAction(eventId: eventId, eventType: eventType, completion: getUserEvents)
                        })
                    })
                    SectionDivider(title: "Unregistered", image: "person.crop.circle.badge.xmark", content: {
                        Events(unregisteredEvents: viewModel.completeUserEvent?.unregisteredEvents, onTapEventAction: { eventId, eventType in
                            onTapEventAction(eventId: eventId, eventType: eventType, completion: getUserEvents)
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
            getUserEvents()
        }
    }
 
    func getUserEvents() -> Void {
        user.autoLogin(completion: {
            user.userEvents(completion: loadUserEvents)
        })
    }
    
    func loadUserEvents(result: Result<Response.KronoxCompleteUserEvent, Error>) -> Void {
        DispatchQueue.main.async {
            switch result {
            case .success(let events):
                viewModel.loadUserEvents(events: events, completion: {
                    self.state = .loaded
                })
            case .failure(let failure):
                AppLogger.shared.info("\(failure.localizedDescription)")
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
