//
//  ResourceRoomSelection.swift
//  Tumble
//
//  Created by Adis Veletanlic on 2023-03-22.
//

import SwiftUI

enum BookingButtonState {
    case loading
    case booked
    case available
}

struct TimeslotSelection: View {
    let resourceId: String
    let bookResource: (String, Date, Response.AvailabilityValue) -> Void
    let selectedPickerDate: Date
    let makeToast: (Bool) -> Void
    let updateBookingNotifications: () -> Void
    @State var buttonStateMap: [String: BookingButtonState] = [:]
    @Binding var availabilityValues: [Response.AvailabilityValue]
    
    init(
        resourceId: String,
        bookResource: @escaping (String, Date, Response.AvailabilityValue) -> Void,
        selectedPickerDate: Date, makeToast: @escaping (Bool) -> Void, updateBookingNotifications: @escaping () -> Void,
        availabilityValues: Binding<[Response.AvailabilityValue]>) {
            self.resourceId = resourceId
            self.bookResource = bookResource
            self.selectedPickerDate = selectedPickerDate
            self.makeToast = makeToast
            self.updateBookingNotifications = updateBookingNotifications
            self._availabilityValues = availabilityValues
            
            for availabilityValue in availabilityValues.wrappedValue {
                if let locationId = availabilityValue.locationID {
                    buttonStateMap[locationId] = .available
                }
            }
    }
    
    var body: some View {
        if availabilityValues.isEmpty {
            VStack {
                Info(title: NSLocalizedString("No available timeslots", comment: ""), image: "clock.arrow.circlepath")
            }.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        } else {
            ScrollView(showsIndicators: false) {
                ForEach(availabilityValues, id: \.self) { availabilityValue in
                    if let locationId = availabilityValue.locationID {
                        TimeslotCard(onBook: {
                            buttonStateMap[locationId] = .loading
                            bookResource(resourceId, selectedPickerDate, availabilityValue)
                        }, locationId: locationId, bookingButtonState: Binding(
                            get: { buttonStateMap[locationId] ?? .available },
                            set: { buttonStateMap[locationId] = $0 }
                        ))
                    }
                }
            }
        }
    }
}
