//
//  UpcomingEventcard.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 2023-03-22.
//

import SwiftUI

struct UpcomingEventCardButton: View {
    
    let event: Response.UpcomingKronoxUserEvent
    
    var body: some View {
        Button(action: {
            
        }, label: {
            HStack {
                VStack (alignment: .leading, spacing: 10) {
                    HStack {
                        Text(event.title)
                            .font(.system(size: 17, weight: .medium))
                            .foregroundColor(.onSurface)
                            .lineLimit(1)
                            .truncationMode(.tail)
                    }
                    HStack {
                        Image(systemName: "calendar.badge.clock")
                            .font(.system(size: 15))
                            .foregroundColor(.onSurface.opacity(0.7))
                        if let eventStart = event.eventStart.toDate(),
                            let eventHoursMinutes = event.eventStart.convertToHoursAndMinutes() {
                            Text(String(format: NSLocalizedString("%@ at %@", comment: ""), eventStart, eventHoursMinutes))
                                .font(.system(size: 15))
                                .foregroundColor(.onSurface.opacity(0.7))

                        } else {
                            Text(NSLocalizedString("No date at this time", comment: ""))
                                .font(.system(size: 15))
                                .foregroundColor(.onSurface.opacity(0.7))
                        }
                    }
                    HStack {
                        Image(systemName: "signature")
                            .font(.system(size: 15))
                            .foregroundColor(.onSurface.opacity(0.7))
                        Text("\(NSLocalizedString("Available at:", comment: "")) \(event.firstSignupDate.toDate() ?? "(no date set)")")
                            .font(.system(size: 15))
                            .foregroundColor(.onSurface.opacity(0.7))

                    }
                }
                
            }
            .padding()
        })
        .buttonStyle(CompactButtonStyle())
    }
}
