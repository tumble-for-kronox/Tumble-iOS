//
//  EventDetailsView.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 2023-01-31.
//

import SwiftUI

struct EventDetailsView: View {
    let event: Response.Event
    let color: Color
    var body: some View {
        ScrollView {
            VStack (spacing: 0) {
                EventDetailsCardView(event: event, color: color)
                EventDetailsBodyView(event: event)
                Spacer()
            }
        }
    }
}
