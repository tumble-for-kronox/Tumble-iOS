//
//  EventDetailsCardView.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 2023-01-31.
//

import SwiftUI

struct EventDetailsCardView: View {
    let event: Response.Event
    let color: Color
    var body: some View {
        VStack (alignment: .leading, spacing: 0) {
            HStack {
                VStack {
                    HStack {
                        VStack (alignment: .leading, spacing: 0) {
                            Text(event.title)
                                .font(.system(size: 28, design: .rounded))
                                .foregroundColor(.background)
                                .padding(.bottom, 7)
                            Text(event.course.englishName)
                                .font(.system(size: 20))
                                .italic()
                                .foregroundColor(.background)
                        }
                        .padding(.bottom, 30)
                        Spacer()
                    }
                    HStack (spacing: 15) {
                        EventDetailsPill(event: event, title: "Notification", image: "bell.badge")
                        EventDetailsPill(event: event, title: "Settings", image: "gear")
                        Spacer()
                    }
                }
                Spacer()
            }
            
        }
        .frame(minWidth: UIScreen.main.bounds.width - 60)
        .padding(15)
        .background(event.isSpecial ? LinearGradient(gradient: Gradient(colors: [.red, .red.opacity(0.7)]), startPoint: .leading, endPoint: .trailing) : LinearGradient(gradient: Gradient(colors: [color, color.opacity(0.7)]), startPoint: .leading, endPoint: .trailing))
        .cornerRadius(20)
        .padding(.all, 15)
    }
}
