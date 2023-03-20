//
//  BookmarkCalendarDetail.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 2023-03-18.
//

import SwiftUI

struct BookmarkCalendarDetail: View {
    
    let onTapDetail: (Response.Event, Color) -> Void
    let event: Response.Event
    let color: Color
    
    var body: some View {
        Button(action: {
            HapticsController.triggerHapticLight()
            onTapDetail(event, color)
        }, label: {
            CompactEventButtonLabel(event: event, color: color)
        })
        .buttonStyle(CompactButtonStyle(backgroundColor: color.opacity(0.15)))
        .padding(.horizontal, 15)
    }
}
