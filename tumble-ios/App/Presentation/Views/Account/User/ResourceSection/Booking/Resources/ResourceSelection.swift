//
//  ResourceSelection.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 2023-03-22.
//

import SwiftUI

struct ResourceSelection: View {
    
    @ObservedObject var parentViewModel: ResourceViewModel
    @State private var selectedTimeIndex: Int = 0
    @State private var availabilityValues: [Response.AvailabilityValue] = [Response.AvailabilityValue]()
    @State private var toast: Toast? = nil
    
    let resource: Response.KronoxResourceElement
    let selectedPickerDate: Date
    let updateBookingNotifications: () -> Void
    
    var body: some View {
        if let timeslots = resource.timeSlots {
            VStack (alignment: .leading) {
                Text(selectedPickerDate.formatDate())
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundColor(.onBackground)
                    .padding(.horizontal, 15)
                    .padding(.vertical, 20)
                ResourceTimeDropdownMenu(
                    resource: resource,
                    timeslots: timeslots,
                    selectedIndex: $selectedTimeIndex
                )
                Divider()
                    .foregroundColor(.onBackground)
                ResourceRoomSelection(
                    resourceId: resource.id ?? "",
                    bookResource: bookResource,
                    selectedPickerDate: selectedPickerDate,
                    makeToast: makeToast,
                    updateBookingNotifications: updateBookingNotifications,
                    availabilityValues: $availabilityValues
                )
            }
            .frame(
                maxWidth: .infinity,
                maxHeight: .infinity,
                alignment: .top
            )
            .background(Color(UIColor.systemBackground))
            .onAppear {
                for timeslot in timeslots {
                    if let timeslotId = timeslot.id,
                       resource.availabilities.timeslotHasAvailable(for: timeslotId) {
                        selectedTimeIndex = timeslotId
                        break
                    }
                }
                availabilityValues = resource.availabilities.getAvailabilityValues(for: selectedTimeIndex)
            }
            .onChange(of: selectedTimeIndex, perform: { _ in
                availabilityValues = resource.availabilities.getAvailabilityValues(for: selectedTimeIndex)
            })
            .toastView(toast: $toast)
        } else {
            Info(title: NSLocalizedString("No available timeslots", comment: ""), image: "clock.arrow.circlepath")
                .frame(
                    maxWidth: .infinity,
                    maxHeight: .infinity,
                    alignment: .center
                )
        }
    }
    
    fileprivate func makeToast(success: Bool) -> Void {
        if success {
            toast = Toast(
                type: .success,
                title: NSLocalizedString("Booked", comment: ""),
                message: NSLocalizedString("Successfully booked resource", comment: ""))
        } else {
            toast = Toast(
                type: .error,
                title: NSLocalizedString("Not booked", comment: ""),
                message: NSLocalizedString("Failed to book the specified resource", comment: ""))
        }
    }

    fileprivate func bookResource(
        resourceId: String,
        date: Date,
        availabilityValue: Response.AvailabilityValue,
        closure: @escaping (Result<Void, Error>) -> Void
    ) -> Void {
            parentViewModel.bookResource(
                resourceId: resourceId,
                date: date,
                availabilityValue: availabilityValue,
                completion: closure
            )
        }
    
}
