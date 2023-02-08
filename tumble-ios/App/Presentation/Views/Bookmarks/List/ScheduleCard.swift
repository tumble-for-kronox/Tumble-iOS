//
//  ScheduleCardview.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 11/18/22.
//

import SwiftUI

struct ScheduleCard: View {
    @State private var isDisclosed: Bool = false
    
    let onTapCard: OnTapCard
    let event: Response.Event
    let isLast: Bool
    let color: Color
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 7.5)
                .fill(event.isSpecial ? .red : color)
                
            Rectangle()
                .fill(Color.surface)
                .offset(x: 7.5)
                .cornerRadius(5, corners: [.topRight, .bottomRight])
            VStack (alignment: .leading, spacing: 0) {
                CardBanner(color: event.isSpecial ? .red : color, timeSpan: "\(event.from.ISOtoHoursAndMinutes()) - \(event.to.ISOtoHoursAndMinutes())", isSpecial: event.isSpecial, courseName: event.course.englishName, isDisclosed: isDisclosed)
                    
                CardInformation(title: event.title, courseName: event.course.englishName.trimmingCharacters(in: .whitespaces), location: event.locations.first?.id ?? "Unknown")
                Spacer()
            }
            
        }
        
        .onTapGesture {
            onTapCard(event, color)
        }
        .frame(height: 140)
        .padding([.leading, .trailing], 8)
        .padding(.bottom, isLast ? 40 : 10)
        
    }
}

