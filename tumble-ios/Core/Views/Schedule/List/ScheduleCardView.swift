//
//  ScheduleCardview.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 11/18/22.
//

import SwiftUI

struct ScheduleCardView: View {
    @AppStorage(UserDefaults.StoreKey.theme.rawValue) private var isDarkMode = false
    @State private var isDisclosed: Bool = false
    let event: API.Types.Response.Event
    let isLast: Bool
    let color: Color
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10)
                .fill(event.isSpecial ? .red : color)
                .shadow(radius: 1)
            Rectangle()
                .fill(Color(isDarkMode ? "SurfaceColor" : "BackgroundColor"))
                .offset(x: 10)
                .cornerRadius(8, corners: [.topRight, .bottomRight])
            VStack (alignment: .leading, spacing: 0) {
                CardBannerView(color: event.isSpecial ? .red : color, timeSpan: "\(event.from.ISOtoHours()) - \(event.to.ISOtoHours())", isSpecial: event.isSpecial, courseName: event.course.englishName, isDisclosed: isDisclosed)
                    
                if isDisclosed {
                    CardInformationView(title: event.title, courseName: event.course.englishName.trimmingCharacters(in: .whitespaces), location: event.locations.first?.id ?? "Unknown")
                        
                }
                Spacer()
            }
            
        }
        .onTapGesture {
            withAnimation {
                isDisclosed.toggle()
            }
        }
        .onLongPressGesture {
            print("long press!")
        }
        
        .frame(height: isDisclosed ? 145 : 50)
        .padding(.leading, 8)
        .padding(.trailing, 8)
        .padding(.bottom, isLast ? 40 : 0)
    }
}

