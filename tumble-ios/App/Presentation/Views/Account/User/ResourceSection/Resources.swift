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
                                        onClickResource: onClickResource,
                                        state: $parentViewModel.bookingSectionState,
                                        bookings: parentViewModel.userBookings)
            }
            ResourceSectionDivider (title: "Your events", resourceType: .event,
                         destination: AnyView(
                            EventBookings(viewModel: parentViewModel)
                                .customNavigationBackButton(previousPage: "Account"))) {
                                    RegisteredEvents(
                                        onClickEvent: onClickEvent,
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
        .sheet(item: $parentViewModel.examDetailSheetModel, content: { examDetails in
            ExamDetailsSheet(event: examDetails.event)
        })
        .sheet(item: $parentViewModel.resourceDetailsSheetModel, content: { resourceDetails in
            ResourceDetailSheet(resource: resourceDetails.resource)
        })
    }
    
    fileprivate func onClickResource(resource: Response.KronoxUserBookingElement) -> Void {
        AppLogger.shared.info("Clicked resource")
        parentViewModel.resourceDetailsSheetModel = ResourceDetailSheetModel(resource: resource)
    }
    
    fileprivate func onClickEvent(event: Response.AvailableKronoxUserEvent) -> Void {
        parentViewModel.examDetailSheetModel = ExamDetailSheetModel(event: event)
    }
    
    
}

