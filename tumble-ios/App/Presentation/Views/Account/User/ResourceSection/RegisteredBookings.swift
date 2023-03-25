//
//  Bookings.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 2023-02-16.
//

import SwiftUI

struct RegisteredBookings: View {
    
    let onClickResource: (Response.KronoxUserBookingElement) -> Void
    @Binding var state: PageState
    let bookings: Response.KronoxUserBookings?
    
    var body: some View {
        VStack {
            switch state {
            case .loading:
                CustomProgressIndicator()
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.top)
            case .loaded:
                if let bookings = bookings {
                    if !bookings.isEmpty {
                        ForEach(bookings) { resource in
                            ResourceCard(
                                timeSpan: "\(resource.timeSlot.from?.convertToHoursAndMinutes() ?? "")",
                                title: "Booked resource",
                                location: resource.locationID,
                                date: resource.timeSlot.from?.toDate() ?? "(no date)",
                                hoursMinutes: "\(resource.timeSlot.from?.convertToHoursAndMinutes() ?? "(no time)") - \(resource.timeSlot.to?.convertToHoursAndMinutes() ?? "(no time)")",
                                onClick: {
                                    onClickResource(resource)
                                }
                            )
                        }
                    } else {
                        Text("No booked resources yet")
                            .sectionDividerEmpty()
                    }
                } else {
                    Text("No booked resources yet")
                        .sectionDividerEmpty()
                }
            case .error:
                Text("Could not contact the server")
                    .sectionDividerEmpty()
            }
            Spacer()
        }
        .frame(minHeight: 100)
    }
}

