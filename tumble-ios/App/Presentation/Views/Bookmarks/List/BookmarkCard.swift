//
//  ScheduleCardview.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 11/18/22.
//

import SwiftUI

struct BookmarkCard: View {
    @State private var isDisclosed: Bool = false
    
    let onTapCard: (Response.Event, Color) -> Void
    let event: Response.Event
    let isLast: Bool
    let color: Color
    
    var body: some View {
        Button(action: {
            HapticsController.triggerHapticLight()
            onTapCard(event, color)
        }, label: {
            VerboseEventButtonLabel(event: event, color: color)
        })
        .buttonStyle(BookmarkCardStyle())
        .padding(.bottom, isLast ? 20 : 5)
    }
}
