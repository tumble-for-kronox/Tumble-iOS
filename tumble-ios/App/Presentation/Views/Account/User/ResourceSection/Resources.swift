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
    
    @Namespace var scrollSpace
    @State var scrollOffset: CGFloat = .zero
    @Binding var collapsedHeader: Bool
    
    var body: some View {
        ScrollView (showsIndicators: false) {
            ScrollViewReader { proxy in
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
                    .padding(.top)
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
    
}

fileprivate struct ResourcesScrollViewOffsetPreferenceKey: PreferenceKey {
  static var defaultValue = CGFloat.zero

  static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
    value += nextValue()
  }
}
