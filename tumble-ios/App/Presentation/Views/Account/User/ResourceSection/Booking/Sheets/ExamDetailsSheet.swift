//
//  ExamDetailsSheet.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 2023-03-24.
//

import SwiftUI

struct ExamDetailsSheet: View {
    
    let event: Response.AvailableKronoxUserEvent
    let getResourcesAndEvents: () -> Void
    let unregisterEvent: (String) -> Void
    
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        VStack (alignment: .leading) {
            HStack {
                Text("Event details")
                    .sheetTitle()
                Spacer()
            }
            VStack {
                Divider()
                DetailsBuilder(title: "Title", image: "a.magnify", content: {
                    Text(event.title ?? "No title")
                        .font(.system(size: 16))
                        .foregroundColor(.onSurface)
                })
                DetailsBuilder(title: "Type", image: "info.circle", content: {
                    Text(event.type ?? "No type")
                        .font(.system(size: 16))
                        .foregroundColor(.onSurface)
                })
                DetailsBuilder(title: "Date", image: "calendar.badge.clock", content: {
                    let date = event.eventStart.toDate() ?? "No date"
                    let start = event.eventStart.convertToHoursAndMinutes() ?? "(no time)"
                    let end = event.eventEnd.convertToHoursAndMinutes() ?? "(no time)"
                    Text("\(date), from \(start) - \(end)")
                        .font(.system(size: 16))
                        .foregroundColor(.onSurface)
                })
                DetailsBuilder(title: "Available until", image: "signature", content: {
                    Text(event.lastSignupDate.toDate() ?? "(no date set)")
                        .font(.system(size: 16))
                        .foregroundColor(.onSurface)
                })
                Button(action: {
                    HapticsController.triggerHapticLight()
                    self.presentationMode.wrappedValue.dismiss()
                    if let id = event.eventId {
                        unregisterEvent(id)
                    }
                }, label: {
                    HStack {
                        Text("Unregister event")
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
