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

struct EventCard: View {
    
    let event: Response.AvailableKronoxUserEvent
    let eventType: EventType
    let onTap: (String, EventType) -> Void
    
    var body: some View {
        VStack (alignment: .trailing, spacing: 0) {
            ZStack {
                RoundedRectangle(cornerRadius: 7.5)
                    .fill(Color.primary)
                Rectangle()
                    .fill(Color.surface)
                    .offset(x: 7.5)
                    .cornerRadius(5, corners: [.topRight, .bottomRight])
                VStack (alignment: .leading, spacing: 0) {
                    EventBanner(eventStart: event.eventStart, eventEnd: event.eventEnd)
                    EventInformation(title: event.title, signUp: event.lastSignupDate, type: .available)
                }
            }
            .frame(height: 140)
            .padding(.vertical, 10)
            .if(!event.lastSignupDate.isValidSignupDate(), transform: { view in
                view.overlay(
                    Image(systemName: "lock.fill")
                        .font(.system(size: 20))
                        .foregroundColor(.onSurface)
                        .padding([.trailing, .bottom], 20)
                    ,alignment: .bottomTrailing
                    
                )
            })
            if event.lastSignupDate.isValidSignupDate() {
                Button(action: {
                    onTap(event.eventId, eventType)
                }, label: {
                    HStack {
                        Image(systemName: eventType.rawValue)
                            .font(.system(size: 18))
                            .foregroundColor(.onPrimary)
                        Text(eventType == .unregister ? "Unregister" : "Register")
                            .font(.system(size: 18, weight: .semibold, design: .rounded))
                            .foregroundColor(.onPrimary)
                    }
                    .padding(10)
                    .background(Color.primary)
                    .cornerRadius(10)
                })
            }
        }
    }
}

