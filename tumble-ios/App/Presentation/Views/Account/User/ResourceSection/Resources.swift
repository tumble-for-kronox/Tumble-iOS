//
//  EventsAndOptions.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 2023-02-15.
//

import SwiftUI

struct Resources: View {
    
    @ObservedObject var parentViewModel: AccountPageViewModel
    
    var body: some View {
        ScrollView (showsIndicators: false) {
            ResourceSectionDivider (title: "User options", image: "gearshape") {
                Toggle(isOn: $parentViewModel.userController.autoSignup) {
                    Text("Automatic exam signup")
                        .sectionDividerEmpty()
                }
                .toggleStyle(SwitchToggleStyle(tint: .primary))
                .onChange(of: parentViewModel.userController.autoSignup, perform: { (value: Bool) in
                    parentViewModel.toggleAutoSignup(value: value)
                    AppLogger.shared.debug("Toggled to \(value)")
                })
            }
            ResourceSectionDivider (title: "Your bookings", image: "books.vertical",
                         destination: AnyView(
                            ResourceBookings(parentViewModel: parentViewModel)
                                .customNavigationBackButton(previousPage: "Account"))) {
                                    RegisteredBookings(
                                        state: $parentViewModel.bookingSectionState,
                                        bookings: parentViewModel.userBookings)
            }
            ResourceSectionDivider (title: "Your events", image: "newspaper",
                         destination: AnyView(
                            EventBookings(viewModel: parentViewModel)
                                .customNavigationBackButton(previousPage: "Account"))) {
                                    RegisteredEvents(
                                        state: $parentViewModel.registeredEventSectionState,
                                        registeredEvents: parentViewModel.completeUserEvent?.registeredEvents)
            }
        }
        .refreshable {
            parentViewModel.getUserBookingsForSection()
            parentViewModel.getUserEventsForSection()
        }
        .frame(maxWidth: .infinity).cornerRadius(20)
        .background(Color.background)
        .cornerRadius(20, corners: [.topLeft, .topRight])
        .padding(.top, 10)
        .onAppear {
            UIRefreshControl.appearance().tintColor = UIColor(named: "PrimaryColor")
        }
    }
}

