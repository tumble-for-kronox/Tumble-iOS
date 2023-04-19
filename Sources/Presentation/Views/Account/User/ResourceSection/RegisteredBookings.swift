//
//  Bookings.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 2023-02-16.
//

import SwiftUI

struct RegisteredBookings: View {
    
    let onClickResource: (Response.KronoxUserBookingElement) -> Void
    @Binding var state: GenericPageStatus
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
                                title: NSLocalizedString("Booked resource", comment: ""),
                                location: resource.locationID,
                                date: resource.timeSlot.from?.toDate() ?? NSLocalizedString("(no date)", comment: ""),
                                hoursMinutes: "\(resource.timeSlot.from?.convertToHoursAndMinutes() ?? NSLocalizedString("(no time)", comment: "")) - \(resource.timeSlot.to?.convertToHoursAndMinutes() ?? NSLocalizedString("(no time)", comment: ""))",
                                onClick: {
                                    onClickResource(resource)
                                }
                            )
                        }
                    } else {
                        Text(NSLocalizedString("No booked resources yet", comment: ""))
                            .sectionDividerEmpty()
                    }
                } else {
                    Text(NSLocalizedString("No booked resources yet", comment: ""))
                        .sectionDividerEmpty()
                }
            case .error:
                Text(NSLocalizedString("Could not contact the server, try again later", comment: ""))
                    .sectionDividerEmpty()
            }
            Spacer()
        }
        .frame(minHeight: 100)
    }
}

