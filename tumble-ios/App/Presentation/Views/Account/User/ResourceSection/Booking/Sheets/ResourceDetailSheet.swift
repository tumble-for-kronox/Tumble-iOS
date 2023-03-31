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
                Text(NSLocalizedString("Resource details", comment: ""))
                    .sheetTitle()
                Spacer()
            }
            VStack {
                Divider()
                DetailsBuilder(title: NSLocalizedString("Location", comment: ""), image: "mappin.and.ellipse", content: {
                    Text(resource.locationID)
                        .font(.system(size: 16))
                        .foregroundColor(.onSurface)
                })
                DetailsBuilder(title: NSLocalizedString("Timeslot", comment: ""), image: "clock.arrow.circlepath", content: {
                    Text("\(resource.timeSlot.from?.convertToHoursAndMinutes() ?? "(no time)") - \(resource.timeSlot.to?.convertToHoursAndMinutes() ?? "(no time")")
                })
                DetailsBuilder(title: NSLocalizedString("Date", comment: ""), image: "calendar.badge.clock", content: {
                    Text(resource.timeSlot.from?.toDate() ?? NSLocalizedString("(no date)", comment: ""))
                        .font(.system(size: 16))
                        .foregroundColor(.onSurface)
                })
                DetailsBuilder(title: NSLocalizedString("Confirmation", comment: ""), image: "checkmark.seal", content: {
                    let date = resource.confirmationOpen.toDate() ?? "(missing)"
                    let from = resource.confirmationOpen.convertToHoursAndMinutes() ?? NSLocalizedString("(missing)", comment: "")
                    let to = resource.confirmationClosed.convertToHoursAndMinutes() ?? NSLocalizedString("(missing)", comment: "")
                    Text(String(format: NSLocalizedString("%@, from %@ - %@", comment: ""), date, from, to))
                        .font(.system(size: 16))
                        .foregroundColor(.onSurface)
                })
                Button(action: {
                    HapticsController.triggerHapticLight()
                    self.presentationMode.wrappedValue.dismiss()
                    unbookResource(resource.id)
                }, label: {
                    HStack {
                        Text(NSLocalizedString("Remove booking", comment: ""))
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
