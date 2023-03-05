//
//  Bookings.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 2023-02-16.
//

import SwiftUI

struct RegisteredBookings: View {
    
    @Binding var state: PageState
    let bookings: Response.KronoxUserBooking?
    
    var body: some View {
        switch state {
        case .loading:
            CustomProgressIndicator()
                .frame(maxWidth: .infinity, alignment: .center)
        case .loaded:
            VStack {
                if let bookings = bookings {
                    if !bookings.isEmpty {
                        ForEach(bookings) { booking in
                            ResourceCard(timeSpan: "\(booking.timeSlot.from.convertToHourMinute() ?? "") - \(booking.timeSlot.to.convertToHourMinute() ?? "")", location: booking.locationID)
                        }
                    } else {
                        Text("No booked resources yet")
                            .sectionDividerEmpty()
                    }
                } else {
                    Text("No booked resources yet")
                        .sectionDividerEmpty()
                }
            }
        case .error:
            Text("Could not contact the server")
                .sectionDividerEmpty()
        }
    }
}

