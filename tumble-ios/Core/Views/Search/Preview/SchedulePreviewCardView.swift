//
//  SchedulePreviewCardView.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 2022-12-02.
//

import SwiftUI

struct SchedulePreviewCardView: View {
    @AppStorage(UserDefaults.StoreKey.theme.rawValue) private var isDarkMode = false
    let previewColor: Color
    let event: API.Types.Response.Event
    let isLast: Bool
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10)
                .fill(event.isSpecial ? .red : previewColor)
                .shadow(radius: 1)
            Rectangle()
                .fill(Color(isDarkMode ? "SurfaceColor" : "BackgroundColor"))
                .offset(x: 10)
                .cornerRadius(8, corners: [.topRight, .bottomRight])
            VStack (alignment: .leading, spacing: 0) {
                PreviewCardBannerView(color: event.isSpecial ? .red : previewColor, timeSpan: "\(event.from.ISOtoHours()) - \(event.to.ISOtoHours())", isSpecial: event.isSpecial)
                PreviewCardInformationView(title: event.title, courseName: event.course.englishName.trimmingCharacters(in: .whitespaces), location: event.locations.first?.id ?? "Unknown")
                Spacer()
            }
            
        }
        .frame(height: 145)
        .padding(.leading, 20)
        .padding(.trailing, 20)
        .padding(.bottom, isLast ? 40 : 0)
    }
}
