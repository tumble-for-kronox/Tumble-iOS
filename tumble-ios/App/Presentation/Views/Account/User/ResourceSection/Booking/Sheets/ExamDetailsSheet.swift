//
//  ExamDetailsSheet.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 2023-03-24.
//

import SwiftUI

struct ExamDetailsSheet: View {
    
    let event: Response.AvailableKronoxUserEvent
    
    var body: some View {
        VStack (alignment: .leading) {
            HStack {
                Text("Event details")
                    .sheetTitle()
                Spacer()
            }
            Divider()
            DetailsBuilder(title: "Title", image: "a.magnify", content: {
                Text(event.title ?? "No title")
                    .font(.system(size: 18))
                    .foregroundColor(.onSurface)
            })
            DetailsBuilder(title: "Type", image: "info.circle", content: {
                Text(event.type ?? "No type")
                    .font(.system(size: 18))
                    .foregroundColor(.onSurface)
            })
            DetailsBuilder(title: "Date", image: "calendar.badge.clock", content: {
                let date = event.eventStart.toDate() ?? "No date"
                let start = event.eventStart.convertToHoursAndMinutes() ?? "(no time)"
                let end = event.eventEnd.convertToHoursAndMinutes() ?? "(no time)"
                Text("\(date), from \(start) - \(end)")
                    .font(.system(size: 18))
                    .foregroundColor(.onSurface)
            })
            Spacer()
        }
        .padding(.horizontal, 15)
    }
}
