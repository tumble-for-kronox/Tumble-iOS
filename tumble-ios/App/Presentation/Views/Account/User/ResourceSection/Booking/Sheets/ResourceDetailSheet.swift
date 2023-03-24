//
//  ResourceDetailSheet.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 2023-03-24.
//

import SwiftUI

struct ResourceDetailSheet: View {
    
    let resource: Response.KronoxUserBookingElement
    
    var body: some View {
        VStack (alignment: .leading) {
            HStack {
                Text("Resource details")
                    .sheetTitle()
                Spacer()
            }
            Divider()
            DetailsBuilder(title: "Location", image: "mappin.and.ellipse", content: {
                Text(resource.locationID)
                    .font(.system(size: 18))
                    .foregroundColor(.onSurface)
            })
            DetailsBuilder(title: "Timeslot", image: "clock.arrow.circlepath", content: {
                Text("\(resource.timeSlot.from?.convertToHoursAndMinutes() ?? "(no time)") - \(resource.timeSlot.to?.convertToHoursAndMinutes() ?? "(no time")")
            })
            DetailsBuilder(title: "Date", image: "calendar.badge.clock", content: {
                Text(resource.timeSlot.from?.toDate() ?? "(no date)")
                    .font(.system(size: 18))
                    .foregroundColor(.onSurface)
            })
            DetailsBuilder(title: "Confirmation", image: "person.badge.shield.checkmark", content: {
                let date = resource.confirmationOpen.toDate() ?? "(missing)"
                let from = resource.confirmationOpen.convertToHoursAndMinutes() ?? "(missing)"
                let to = resource.confirmationClosed.convertToHoursAndMinutes() ?? "(missing)"
                Text("\(date), from \(from) - \(to)")
                    .font(.system(size: 18))
                    .foregroundColor(.onSurface)
            })
            Spacer()
        }
        .padding(.horizontal, 15)
    }
}
