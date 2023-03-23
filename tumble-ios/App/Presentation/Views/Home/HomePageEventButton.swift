//
//  HomePageEventButton.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 2023-03-19.
//

import SwiftUI

struct HomePageEventButton: View {
    
    let onTapEvent: (Response.Event, Color) -> Void
    let event: Response.Event
    let color: Color
    
    var body: some View {
        Button(action: {
            HapticsController.triggerHapticLight()
            onTapEvent(event, color)
        }, label: {
            CompactEventButtonLabel(event: event, color: event.isSpecial ? .red : color)
        })
        .buttonStyle(CompactButtonStyle(backgroundColor: event.isSpecial ? .red.opacity(0.2) : color.opacity(0.15)))
    }
}
