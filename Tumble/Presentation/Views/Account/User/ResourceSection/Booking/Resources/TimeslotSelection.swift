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
    let bookResource: (String, Date, NetworkResponse.AvailabilityValue) async -> Bool
    let selectedPickerDate: Date
    let updateBookingNotifications: () -> Void
    @State var buttonStateMap: [String: BookingButtonState] = [:]
    @Binding var availabilityValues: [NetworkResponse.AvailabilityValue]
    
    init(
        resourceId: String,
        bookResource: @escaping (String, Date, NetworkResponse.AvailabilityValue) async -> Bool,
        selectedPickerDate: Date,
        updateBookingNotifications: @escaping () -> Void,
        availabilityValues: Binding<[NetworkResponse.AvailabilityValue]>) {
            self.resourceId = resourceId
            self.bookResource = bookResource
            self.selectedPickerDate = selectedPickerDate
            self.updateBookingNotifications = updateBookingNotifications
            self._availabilityValues = availabilityValues
            
            setupButtons(for: availabilityValues)
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
                        TimeslotCard(
                            onBook: { handleBooking(for: locationId, with: availabilityValue) },
                            locationId: locationId,
                            bookingButtonState: Binding(
                            get: { buttonStateMap[locationId] ?? .available },
                            set: { buttonStateMap[locationId] = $0 }
                        ))
                    }
                }
            }
        }
    }
    
    private func setupButtons(for availabilityValues: Binding<[NetworkResponse.AvailabilityValue]>) {
        for availabilityValue in availabilityValues.wrappedValue {
            if let locationId = availabilityValue.locationID {
                buttonStateMap[locationId] = .available
            }
        }
    }
    
    private func handleBooking(
        for locationId: String,
        with availabilityValue: NetworkResponse.AvailabilityValue
    ) {
        buttonStateMap[locationId] = .loading
        Task {
            let result = await bookResource(resourceId, selectedPickerDate, availabilityValue)
            DispatchQueue.main.async {
                if result {
                    buttonStateMap[locationId] = .booked
                } else {
                    buttonStateMap[locationId] = .available
                }
            }
        }
    }
    
}
