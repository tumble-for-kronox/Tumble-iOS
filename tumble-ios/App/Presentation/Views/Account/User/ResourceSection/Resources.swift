//
//  EventsAndOptions.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 2023-02-15.
//

import SwiftUI

struct Resources: View {
    
    @ObservedObject var viewModel: AccountPageViewModel
    
    var body: some View {
        ScrollView (showsIndicators: false) {
            ResourceSectionDivider (title: "User options", image: "gearshape") {
                Toggle(isOn: $viewModel.userController.autoSignup) {
                    Text("Automatic exam signup")
                        .sectionDividerEmpty()
                }
                .toggleStyle(SwitchToggleStyle(tint: .primary))
                .onChange(of: viewModel.userController.autoSignup, perform: { (value: Bool) in
                    viewModel.toggleAutoSignup(value: value)
                    AppLogger.shared.info("Toggled to \(value)")
                })
            }
            ResourceSectionDivider (title: "Your bookings", image: "books.vertical",
                         destination: AnyView(
                            ResourceBookings()
                                .customNavigationBackButton(previousPage: "Account"))) {
                                    RegisteredBookings(
                                        state: $viewModel.bookingSectionState,
                                        bookings: viewModel.userBookings)
            }
            ResourceSectionDivider (title: "Your events", image: "newspaper",
                         destination: AnyView(
                            EventBookings(viewModel: viewModel)
                                .customNavigationBackButton(previousPage: "Account"))) {
                                    RegisteredEvents(
                                        state: $viewModel.registeredEventSectionState,
                                        registeredEvents: viewModel.completeUserEvent?.registeredEvents)
            }
        }
        .frame(maxWidth: .infinity).cornerRadius(15)
        .background(Color.background)
        .cornerRadius(20, corners: [.topLeft, .topRight])
        .padding(.top, 10)
        .refreshable {
            viewModel.getUserBookingsForSection()
            viewModel.getUserEventsForSection()
        }
        .onAppear {
            UIRefreshControl.appearance().tintColor = UIColor(named: "PrimaryColor")
        }
    }
}

