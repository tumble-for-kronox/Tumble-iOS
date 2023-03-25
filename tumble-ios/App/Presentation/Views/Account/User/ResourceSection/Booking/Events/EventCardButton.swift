//
//  EventCard.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 2023-02-15.
//

import SwiftUI

enum EventType: String {
    case register = "checkmark.circle.fill"
    case unregister = "xmark.circle.fill"
}

struct EventCardButton: View {
    
    let event: Response.AvailableKronoxUserEvent
    let eventType: EventType
    let onTap: (String, EventType) -> Void
    
    var body: some View {
        VStack {
            HStack {
                VStack (alignment: .leading, spacing: 10) {
                    HStack {
                        Text(event.title ?? "No title")
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
                            Text("\(eventStart) at \(eventHoursMinutes)")
                                .font(.system(size: 15))
                                .foregroundColor(.onSurface.opacity(0.7))
                        } else {
                            Text("No date at this time")
                                .font(.system(size: 15))
                                .foregroundColor(.onSurface.opacity(0.7))
                        }
                    }
                    HStack {
                        Image(systemName: "signature")
                            .font(.system(size: 15))
                            .foregroundColor(.onSurface.opacity(0.7))
                        if event.lastSignupDate.isValidSignupDate() {
                            Text("Available until \(event.lastSignupDate.toDate() ?? "(no date set)")")
                                .font(.system(size: 15))
                                .foregroundColor(.onSurface.opacity(0.7))
                        } else {
                            Text("Signup has passed")
                                .font(.system(size: 15))
                                .foregroundColor(.onSurface.opacity(0.7))
                        }
                    }
                }
                
            }
            .padding()
            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 100, maxHeight: 100, alignment: .center)
            .background(Color.surface)
            .cornerRadius(20)
            if event.lastSignupDate.isValidSignupDate() {
                HStack {
                    Spacer()
                    Button(action: {
                        if let eventId = event.eventId {
                            onTap(eventId, eventType)
                        }
                    }, label: {
                        HStack {
                            Image(systemName: eventType.rawValue)
                                .font(.system(size: 18))
                                .foregroundColor(.onPrimary)
                            Text(eventType == .unregister ? "Unregister" : "Register")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.onPrimary)
                        }
                        .padding(10)
                        .background(Color.primary)
                        .cornerRadius(10)
                    })
                }
            }
        }
        .padding(.bottom, 10)
    }
}

