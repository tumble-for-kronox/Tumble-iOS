//
//  HomePageEventButton.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 2023-03-19.
//

import SwiftUI

struct HomePageEventButton: View {
    
    let onTapEvent: (Response.Event) -> Void
    let event: Response.Event
    let color: Color
    
    var body: some View {
        Button(action: {}, label: {
            CompactEventButtonLabel(event: event, color: color)
        })
        .buttonStyle(CompactButtonStyle(backgroundColor: color.opacity(0.15)))
    }
}