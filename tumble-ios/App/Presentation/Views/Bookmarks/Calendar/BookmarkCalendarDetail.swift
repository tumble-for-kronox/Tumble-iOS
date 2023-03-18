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
            ZStack {
                RoundedRectangle(cornerRadius: 7.5)
                    .fill(event.isSpecial ? .red : color)
                Rectangle()
                    .fill(Color.surface)
                    .offset(x: 7.5)
                    .cornerRadius(5, corners: [.topRight, .bottomRight])
                VStack (alignment: .leading, spacing: 0) {
                    BookmarkCardBanner(color: event.isSpecial ? .red : color, timeSpan: "\(event.from.convertISOToHoursAndMinutes() ?? "") - \(event.to.convertISOToHoursAndMinutes() ?? "")", isSpecial: event.isSpecial, courseName: event.course.englishName)
                    VStack {
                        Text(event.title)
                            .courseNameCalendarDetail()
                        Spacer()
                    }
                    Spacer()
                }
                
            }
        })
        .buttonStyle(BookmarkCalendarDetailStyle())
    }
}
