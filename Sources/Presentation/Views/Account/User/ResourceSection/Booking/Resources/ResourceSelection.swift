//
//  ResourceSelection.swift
//  Tumble
//
//  Created by Adis Veletanlic on 2023-03-22.
//

import SwiftUI

struct ResourceSelection: View {
    @ObservedObject var parentViewModel: ResourceViewModel
    @State private var selectedTimeIndex: Int = 0
    @State private var availabilityValues: [Response.AvailabilityValue] = .init()
    
    let resource: Response.KronoxResourceElement
    let selectedPickerDate: Date
    let updateBookingNotifications: () -> Void
    
    var body: some View {
        if let timeslots = resource.timeSlots {
            VStack(alignment: .leading) {
                Text(selectedPickerDate.formatDate())
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundColor(.onBackground)
                    .padding(.horizontal, 15)
                    .padding(.vertical, 20)
                TimeslotDropdown(
                    resource: resource,
                    timeslots: timeslots,
                    selectedIndex: $selectedTimeIndex
                )
                Divider()
                    .foregroundColor(.onBackground)
                TimeslotSelection(
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
            .background(Color.background)
            .onAppear {
                for timeslot in timeslots {
                    if let timeslotId = timeslot.id,
                       resource.availabilities.timeslotHasAvailable(for: timeslotId)
                    {
                        selectedTimeIndex = timeslotId
                        break
                    }
                }
                availabilityValues = resource.availabilities.getAvailabilityValues(for: selectedTimeIndex)
            }
            .onChange(of: selectedTimeIndex, perform: { _ in
                availabilityValues = resource.availabilities.getAvailabilityValues(for: selectedTimeIndex)
            })
        } else {
            Info(title: NSLocalizedString("No available timeslots", comment: ""), image: "clock.arrow.circlepath")
                .frame(
                    maxWidth: .infinity,
                    maxHeight: .infinity,
                    alignment: .center
                )
        }
    }
    
    fileprivate func makeToast(success: Bool) {
        if success {
            AppController.shared.toast = Toast(
                type: .success,
                title: NSLocalizedString("Booked", comment: ""),
                message: NSLocalizedString("Successfully booked resource", comment: "")
            )
        } else {
            AppController.shared.toast = Toast(
                type: .error,
                title: NSLocalizedString("Not booked", comment: ""),
                message: NSLocalizedString("Failed to book the specified resource", comment: "")
            )
        }
    }

    fileprivate func bookResource(
        resourceId: String,
        date: Date,
        availabilityValue: Response.AvailabilityValue,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        parentViewModel.bookResource(
            resourceId: resourceId,
            date: date,
            availabilityValue: availabilityValue,
            completion: completion
        )
    }
}
