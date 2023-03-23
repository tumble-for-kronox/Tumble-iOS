//
//  ResourceRoomSelection.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 2023-03-22.
//

import SwiftUI

struct ResourceRoomSelection: View {
    
    let resourceId: String
    let bookResource: (String, Date, Response.AvailabilityValue) -> Void
    let selectedPickerDate: Date
    @Binding var availabilityValues: [Response.AvailabilityValue]
    
    var body: some View {
        if availabilityValues.isEmpty {
            VStack {
                Info(title: "No available timeslots", image: "clock.arrow.circlepath")
            }.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        }
        else {
            ScrollView (showsIndicators: false) {
                ForEach(availabilityValues) { availabilityValue in
                    if let locationId = availabilityValue.locationID {
                        RoomContainerCard(onBook: {
                            bookResource(resourceId, selectedPickerDate, availabilityValue)
                        }, locationId: locationId)
                    }
                }
            }
        }
    }
}

