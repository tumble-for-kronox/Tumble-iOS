//
//  EventsAndOptions.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 2023-02-15.
//

import SwiftUI

struct Resources: View {
    
    @ObservedObject var viewModel: AccountPageViewModel
    @EnvironmentObject var user: UserController
    @Binding var autoSignup: Bool
    
    @State private var bookingsState: PageState = .loading
    @State private var registeredEventsState: PageState = .loading
    
    let toggleAutoSignup: (Bool) -> Void
    
    var body: some View {
        ScrollView (.vertical) {
            ResourceSectionDivider (title: "User options", image: "gearshape") {
                Toggle(isOn: $autoSignup) {
                    Text("Automatic exam signup")
                        .sectionDividerEmpty()
                }
                .toggleStyle(SwitchToggleStyle(tint: .primary))
                .onChange(of: autoSignup, perform: { (value: Bool) in
                    toggleAutoSignup(value)
                })
            }
            ResourceSectionDivider (title: "Your bookings", image: "books.vertical",
                         destination: AnyView(
                            ResourceBookings()
                                .environmentObject(user)
                                .customNavigationBackButton(previousPage: "Account"))) {
                                    RegisteredBookings(state: $bookingsState, bookings: user.userBookings)
            }
            ResourceSectionDivider (title: "Your exams", image: "newspaper",
                         destination: AnyView(
                            EventBookings(viewModel: viewModel)
                                .environmentObject(user)
                                .customNavigationBackButton(previousPage: "Account"))) {
                                    RegisteredEvents(state: $registeredEventsState, registeredEvents: user.completeUserEvent?.registeredEvents)
            }
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: UIScreen.main.bounds.height / 1.65).cornerRadius(15)
        .background(Color.background)
        .cornerRadius(15, corners: [.topLeft, .topRight])
        .onAppear {
            loadUserValues()
        }
    }

    fileprivate func loadUserValues() -> Void {
        user.getUserEvents(completion: { success in
            DispatchQueue.main.async {
                if success {
                    user.getUserBookings(completion: setState)
                    self.registeredEventsState = .loaded
                } else {
                    self.registeredEventsState = .error
                    self.bookingsState = .error
                }
            }
        })
    }
    
    fileprivate func setState(success: Bool) -> Void {
        DispatchQueue.main.async {
            if success {
                self.bookingsState = .loaded
            } else {
                self.bookingsState = .error
            }
        }
    }
    
}

