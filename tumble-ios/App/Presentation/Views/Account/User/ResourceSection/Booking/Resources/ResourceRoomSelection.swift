//
//  ResourceRoomSelection.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 2023-03-22.
//

import SwiftUI

enum BookingButtonState {
    case loading
    case booked
    case available
}

struct ResourceRoomSelection: View {
    
    let resourceId: String
    let bookResource: (String, Date, Response.AvailabilityValue, @escaping (Result<Void, Error>) -> Void) -> Void
    let selectedPickerDate: Date
    let makeToast: (Bool) -> Void
    @State var buttonStateMap: [String : BookingButtonState] = [:]
    @Binding var availabilityValues: [Response.AvailabilityValue]
    
    var body: some View {
        if availabilityValues.isEmpty {
            VStack {
                Info(title: "No available timeslots", image: "clock.arrow.circlepath")
            }.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        }
        else {
            ScrollView (showsIndicators: false) {
                ForEach(availabilityValues, id: \.self) { availabilityValue in
                    if let locationId = availabilityValue.locationID {
                        RoomContainerCard(onBook: {
                            buttonStateMap[locationId] = .loading
                            bookResource(resourceId, selectedPickerDate, availabilityValue) { result in
                                handleBookingResponse(locationId: locationId, result: result)
                            }
                        }, locationId: locationId, bookingButtonState: Binding(
                            get: { buttonStateMap[locationId] ?? .loading },
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
    
    func handleBookingResponse(locationId: String, result: Result<Void, Error>) -> Void {
        switch result {
        case .success:
            buttonStateMap[locationId] = .booked
            makeToast(true)
        case .failure:
            buttonStateMap[locationId] = .available
            makeToast(false)
        }
    }
}

