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
    let bookResource: (String, Date, Response.AvailabilityValue, @escaping (Result<Void, Error>) -> Void) -> Void
    let selectedPickerDate: Date
    let makeToast: (Bool) -> Void
    let updateBookingNotifications: () -> Void
    @State var buttonStateMap: [String: BookingButtonState] = [:]
    @Binding var availabilityValues: [Response.AvailabilityValue]
    
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
                            bookResource(resourceId, selectedPickerDate, availabilityValue) { result in
                                handleBookingResponse(locationId: locationId, result: result)
                            }
                        }, locationId: locationId, bookingButtonState: Binding(
                            get: { buttonStateMap[locationId] ?? .available },
                            set: { buttonStateMap[locationId] = $0 }
                        ))
                    }
                }
            }
            .onAppear {
                for availabilityValue in availabilityValues {
                    if let locationId = availabilityValue.locationID {
                        buttonStateMap[locationId] = .available
                    }
                }
            }
        }
    }
    
    func handleBookingResponse(locationId: String, result: Result<Void, Error>) {
        switch result {
        case .success:
            buttonStateMap[locationId] = .booked
            updateBookingNotifications()
            makeToast(true)
        case .failure:
            buttonStateMap[locationId] = .available
            makeToast(false)
        }
    }
}
