//
//  EventsAndOptions.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 2023-02-15.
//

import SwiftUI

struct Resources: View {
    
    @ObservedObject var parentViewModel: AccountViewModel
    let getResourcesAndEvents: () -> Void
    let createToast: (ToastStyle, String, String) -> Void
    
    @Namespace var scrollSpace
    @State var scrollOffset: CGFloat = .zero
    @Binding var collapsedHeader: Bool
    
    @State private var isAutoSignupEnabled: Bool
        
    init(
        parentViewModel: AccountViewModel,
        getResourcesAndEvents: @escaping () -> Void,
        createToast: @escaping (ToastStyle, String, String) -> Void,
        collapsedHeader: Binding<Bool>
    ) {
        self._isAutoSignupEnabled = State(initialValue: parentViewModel.userController.autoSignup)
        self.parentViewModel = parentViewModel
        self.getResourcesAndEvents = getResourcesAndEvents
        self.createToast = createToast
        self._collapsedHeader = collapsedHeader
    }
    
    var body: some View {
        ScrollView (showsIndicators: false) {
            ScrollViewReader { proxy in
                VStack {
                    ResourceSectionDivider (title: "User options") {
                        Toggle(isOn: $isAutoSignupEnabled) {
                            Text("Automatic exam signup")
                                .sectionDividerEmpty()
                        }
                        .onChange(of: isAutoSignupEnabled, perform: toggleAutomaticExamSignup)
                        .padding(.bottom)
                        .toggleStyle(SwitchToggleStyle(tint: .primary))
                        
                    }
                    .padding(.top)
                    ResourceSectionDivider (title: "Your bookings", resourceType: .resource,
                                 destination: AnyView(
                                    ResourceBookings(viewModel: parentViewModel.resourceViewModel)
                                        .customNavigationBackButton(previousPage: "Account"))) {
                                            RegisteredBookings(
                                                onClickResource: onClickResource,
                                                state: $parentViewModel.bookingSectionState,
                                                bookings: parentViewModel.userBookings)
                    }
                    ResourceSectionDivider (title: "Your events", resourceType: .event,
                                 destination: AnyView(
                                    EventBookings(
                                        viewModel: parentViewModel.resourceViewModel,
                                        getUserEventsForSection: getUserEventsForSection
                                    )
                                        .customNavigationBackButton(previousPage: "Account"))) {
                                            RegisteredEvents(
                                                onClickEvent: onClickEvent,
                                                state: $parentViewModel.registeredEventSectionState,
                                                registeredEvents: parentViewModel.completeUserEvent?.registeredEvents)
                    }
                }
                .background(GeometryReader { geo in
                    let offset = -geo.frame(in: .named(scrollSpace)).minY
                    Color.clear
                        .preference(key: ResourcesScrollViewOffsetPreferenceKey.self,
                                    value: offset)
                })
            }
        }
        .coordinateSpace(name: scrollSpace)
        .onPreferenceChange(ResourcesScrollViewOffsetPreferenceKey.self, perform: handleScroll)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.background)
        .cornerRadius(20, corners: [.topLeft, .topRight])
        .refreshable {
            getResourcesAndEvents()
        }
        .onAppear {
            UIRefreshControl.appearance().tintColor = UIColor(named: "PrimaryColor")
        }
        .sheet(item: $parentViewModel.examDetailSheetModel, content: { examDetails in
            ExamDetailsSheet(
                event: examDetails.event,
                getResourcesAndEvents: getResourcesAndEvents,
                unregisterEvent: unregisterEvent
            )
        })
        .sheet(item: $parentViewModel.resourceDetailsSheetModel, content: { resourceDetails in
            ResourceDetailSheet(
                resource: resourceDetails.resource,
                unbookResource: unbookResource,
                getResourcesAndEvents: getResourcesAndEvents
            )
        })
    }
    
    fileprivate func getUserEventsForSection() -> Void {
        parentViewModel.getUserEventsForSection()
    }
    
    fileprivate func onClickResource(resource: Response.KronoxUserBookingElement) -> Void {
        parentViewModel.resourceDetailsSheetModel = ResourceDetailSheetModel(resource: resource)
    }
    
    fileprivate func onClickEvent(event: Response.AvailableKronoxUserEvent) -> Void {
        parentViewModel.examDetailSheetModel = ExamDetailSheetModel(event: event)
    }
    
    fileprivate func handleScroll(value: CGFloat) -> Void {
        scrollOffset = value
        if scrollOffset >= 80 {
            withAnimation(.easeInOut) {
                collapsedHeader = true
            }
        } else {
            withAnimation(.easeInOut) {
                collapsedHeader = false
            }
        }
    }
    
    fileprivate func unregisterEvent(eventId: String) -> Void {
        parentViewModel.registeredEventSectionState = .loading
        parentViewModel.unregisterForEvent(eventId: eventId) { result in
            switch result {
            case .success:
                AppLogger.shared.info("Unregistered for event: \(eventId)")
                parentViewModel.removeUserEvent(where: eventId)
                DispatchQueue.main.async {
                    parentViewModel.registeredEventSectionState = .loaded
                }
                createToast(.success, "Unregistered from event", "You have been unregistered from the specified event")
            case .failure:
                AppLogger.shared.critical("Failed to unregister for event: \(eventId)")
                DispatchQueue.main.async {
                    parentViewModel.registeredEventSectionState = .error
                }
                createToast(.error, "Error", "We couldnt unregister you for the specified event")
            }
        }
    }
    
    fileprivate func unbookResource(bookingId: String) -> Void {
        parentViewModel.bookingSectionState = .loading
        parentViewModel.resourceViewModel.unbookResource(bookingId: bookingId, completion: { result in
            switch result {
            case .success:
                AppLogger.shared.info("Unbooked resource: \(bookingId)")
                parentViewModel.removeUserBooking(where: bookingId)
                DispatchQueue.main.async {
                    parentViewModel.bookingSectionState = .loaded
                }
                createToast(.success, "Unbooked resource", "You have unbooked the selected resource")
            case .failure:
                AppLogger.shared.critical("Failed to unbook resource: \(bookingId)")
                DispatchQueue.main.async {
                    parentViewModel.bookingSectionState = .error
                }
                createToast(.error, "Error", "We couldn't unbook the specified resource")
            }
        })
    }
    
    fileprivate func toggleAutomaticExamSignup(value: Bool) -> Void {
        parentViewModel.toggleAutoSignup(value: value)
        if value {
            createToast(.info, "Automatic signup", "Automatic exam/event signup has been enabled, but make sure you are always registered for exams through your institution.")
        } else {
            createToast(.info, "Automatic signup", "Automatic exam/event signup has been disabled.")
        }
        AppLogger.shared.info("Toggled to \(value)")
    }
    
}

fileprivate struct ResourcesScrollViewOffsetPreferenceKey: PreferenceKey {
  static var defaultValue = CGFloat.zero

  static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
    value += nextValue()
  }
}
