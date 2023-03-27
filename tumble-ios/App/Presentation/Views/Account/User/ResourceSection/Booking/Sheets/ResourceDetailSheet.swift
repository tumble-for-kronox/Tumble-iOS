//
//  ResourceDetailSheet.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 2023-03-24.
//

import SwiftUI

struct ResourceDetailSheet: View {
    
    let resource: Response.KronoxUserBookingElement
    let unbookResource: (String) -> Void
    let getResourcesAndEvents: () -> Void
    
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        VStack (alignment: .leading) {
            HStack {
                Text("Resource details")
                    .sheetTitle()
                Spacer()
            }
            VStack {
                Divider()
                DetailsBuilder(title: "Location", image: "mappin.and.ellipse", content: {
                    Text(resource.locationID)
                        .font(.system(size: 16))
                        .foregroundColor(.onSurface)
                })
                DetailsBuilder(title: "Timeslot", image: "clock.arrow.circlepath", content: {
                    Text("\(resource.timeSlot.from?.convertToHoursAndMinutes() ?? "(no time)") - \(resource.timeSlot.to?.convertToHoursAndMinutes() ?? "(no time")")
                })
                DetailsBuilder(title: "Date", image: "calendar.badge.clock", content: {
                    Text(resource.timeSlot.from?.toDate() ?? "(no date)")
                        .font(.system(size: 16))
                        .foregroundColor(.onSurface)
                })
                DetailsBuilder(title: "Confirmation", image: "checkmark.seal", content: {
                    let date = resource.confirmationOpen.toDate() ?? "(missing)"
                    let from = resource.confirmationOpen.convertToHoursAndMinutes() ?? "(missing)"
                    let to = resource.confirmationClosed.convertToHoursAndMinutes() ?? "(missing)"
                    Text("\(date), from \(from) - \(to)")
                        .font(.system(size: 16))
                        .foregroundColor(.onSurface)
                })
                Button(action: {
                    HapticsController.triggerHapticLight()
                    self.presentationMode.wrappedValue.dismiss()
                    unbookResource(resource.id)
                }, label: {
                    HStack {
                        Text("Remove booking")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundColor(.onPrimary)
                    }
                })
                .buttonStyle(WideAnimatedButtonStyle())
                .padding(.top, 20)
                Spacer()
            }
        }
        .padding(.horizontal, 15)
    }
}
