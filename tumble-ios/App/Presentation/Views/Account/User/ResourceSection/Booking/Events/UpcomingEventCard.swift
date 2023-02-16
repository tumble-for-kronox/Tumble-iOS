//
//  UpcomingEventCard.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 2023-02-15.
//

import SwiftUI

struct UpcomingEventCard: View {
    
    let event: Response.UpcomingKronoxUserEvent
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 7.5)
                .fill(Color.primary)
            Rectangle()
                .fill(Color.surface)
                .offset(x: 7.5)
                .cornerRadius(5, corners: [.topRight, .bottomRight])
            VStack (alignment: .leading, spacing: 0) {
                EventBanner(eventStart: event.eventStart, eventEnd: event.eventEnd)
                EventInformation(title: event.title, signUp: event.firstSignupDate, type: .upcoming)
            }
        }
        .frame(height: 140)
        .padding(.vertical, 10)
    }
}

