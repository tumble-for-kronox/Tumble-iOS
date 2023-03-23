//
//  EventsAndOptions.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 2023-02-15.
//

import SwiftUI

struct Resources: View {
    
    @ObservedObject var parentViewModel: AccountViewModel
    
    var body: some View {
        VStack {
            ResourceSectionDivider (title: "User options") {
                Toggle(isOn: $parentViewModel.userController.autoSignup) {
                    Text("Automatic exam signup")
                        .sectionDividerEmpty()
                }
                .padding(.bottom)
                .toggleStyle(SwitchToggleStyle(tint: .primary))
                .onChange(of: parentViewModel.userController.autoSignup, perform: { (value: Bool) in
                    parentViewModel.toggleAutoSignup(value: value)
                    AppLogger.shared.info("Toggled to \(value)")
                })
            }
            ResourceSectionDivider (title: "Your bookings", resourceType: .resource,
                         destination: AnyView(
                            ResourceBookings(parentViewModel: parentViewModel)
                                .customNavigationBackButton(previousPage: "Account"))) {
                                    RegisteredBookings(
                                        state: $parentViewModel.bookingSectionState,
                                        bookings: parentViewModel.userBookings)
            }
            ResourceSectionDivider (title: "Your events", resourceType: .event,
                         destination: AnyView(
                            EventBookings(viewModel: parentViewModel)
                                .customNavigationBackButton(previousPage: "Account"))) {
                                    RegisteredEvents(
                                        state: $parentViewModel.registeredEventSectionState,
                                        registeredEvents: parentViewModel.completeUserEvent?.registeredEvents)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.background)
        .cornerRadius(20, corners: [.topLeft, .topRight])
        .onAppear {
            UIRefreshControl.appearance().tintColor = UIColor(named: "PrimaryColor")
        }
    }
}

