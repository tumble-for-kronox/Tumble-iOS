//
//  ResourceDetailSheet.swift
//  Tumble
//
//  Created by Adis Veletanlic on 2023-03-24.
//

import SwiftUI

struct ResourceDetailSheet: View {
    let resource: Response.KronoxUserBookingElement
    let unbookResource: (String) -> Void
    let confirmResource: (String, String) -> Void
    let getResourcesAndEvents: () -> Void
    
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack {
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
            if let confirmationOpen = resource.confirmationOpen, let confirmationClosed = resource.confirmationClosed {
                DetailsBuilder(title: NSLocalizedString("Confirmation", comment: ""), image: "checkmark.seal", content: {
                    let date = confirmationOpen.toDate() ?? "(missing)"
                    let from = confirmationOpen.convertToHoursAndMinutes() ?? NSLocalizedString("(missing)", comment: "")
                    let to = confirmationClosed.convertToHoursAndMinutes() ?? NSLocalizedString("(missing)", comment: "")
                    Text(String(format: NSLocalizedString("%@, from %@ - %@", comment: ""), date, from, to))
                        .font(.system(size: 16))
                        .foregroundColor(.onSurface)
                })
            }
            Spacer()
            if resource.showConfirmButton {
                Button(action: {
                    HapticsController.triggerHapticLight()
                    dismiss()
                    confirmResource(resource.resourceID, resource.id)
                }, label: {
                    HStack {
                        Text(NSLocalizedString("Confirm booking", comment: ""))
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.onPrimary)
                    }
                })
                .buttonStyle(WideAnimatedButtonStyle())
                .padding(.horizontal, 15)
                .padding(.top, 20)
            }
            if resource.showUnbookButton {
                Button(action: {
                    HapticsController.triggerHapticLight()
                    dismiss()
                    unbookResource(resource.id)
                }, label: {
                    HStack {
                        Text(NSLocalizedString("Remove booking", comment: ""))
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.onPrimary)
                    }
                })
                .buttonStyle(WideAnimatedButtonStyle(color: .red))
                .padding(.horizontal, 15)
                .padding(.top, 20)
            }
        }
        .padding(.top, 55)
        .background(Color.background)
        .overlay(
            CloseCoverButton(onClick: {
                dismiss()
            }),
            alignment: .topTrailing
        )
        .overlay(
            Text(NSLocalizedString("Resource details", comment: ""))
                .sheetTitle()
            ,alignment: .top
        )
    }
    
    func bookingCanBeConfirmed() -> Bool {
        let currentDate = Date()
        guard let confirmationOpen = resource.confirmationOpen, let confirmationClosed = resource.confirmationClosed else {
            return false
        }
        if let confirmationOpen = dateFormatterUTC.date(from: confirmationOpen),
           let confirmationClosed = dateFormatterUTC.date(from: confirmationClosed)
        {
            return currentDate > confirmationOpen && currentDate < confirmationClosed
        }
        return false
    }
}
