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
                HStack {
                    Circle()
                        .foregroundColor(event.isSpecial ? .red : previewColor)
                        .frame(height: 7)
                    Text("\(event.from.ISOtoHours()) - \(event.to.ISOtoHours())")
                        .font(.subheadline)
                        .foregroundColor(Color("OnSurface"))
                    Spacer()
                    if event.isSpecial {
                        Image(systemName: "person.crop.circle.badge.exclamationmark")
                            .font(.title3)
                            .foregroundColor(Color("OnSurface"))
                            .padding(.trailing, 15)
                    }
                }
                .padding(.top, 20)
                .padding(.leading, 25)
                .padding(.bottom, 10)
                VStack (alignment: .leading) {
                    Text(event.title)
                        .font(.title2)
                        .foregroundColor(Color("OnSurface"))
                        .padding(.leading, 25)
                        .padding(.trailing, 25)
                        .padding(.bottom, 2.5)
                    VStack {
                        Text(event.course.englishName.trimmingCharacters(in: .whitespaces))
                            .font(.title3)
                            .foregroundColor(Color("OnSurface"))
                            .padding(.leading, 25)
                            .padding(.bottom, 10)
                        Spacer()
                    }
                    HStack {
                        Spacer()
                        Text(event.locations.first?.id ?? "Unknown")
                            .font(.title3)
                            .foregroundColor(Color("OnSurface"))
                        Image(systemName: "location")
                            .font(.title3)
                            .foregroundColor(Color("OnSurface"))
                            .padding(.trailing, 5)
                    }
                    .padding(.trailing, 10)
                    Spacer()
                }
                Spacer()
            }
            
        }
        .frame(height: 155)
        .padding(.leading, 20)
        .padding(.trailing, 20)
        .padding(.bottom, isLast ? 40 : 0)
    }
}
