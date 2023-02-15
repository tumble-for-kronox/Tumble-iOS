//
//  EventBanner.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 2023-02-15.
//

import SwiftUI

struct EventBanner: View {
    
    let eventStart: String
    let eventEnd: String
    
    var body: some View {
        HStack {
            Circle()
                .foregroundColor(Color.primary)
                .frame(height: 7)
            Text("\(eventStart.convertToHourMinute() ?? "") - \(eventEnd.convertToHourMinute() ?? "")")
                .timeSpanCard()
            Spacer()
            Text(eventStart.toDate() ?? "")
                .timeSpanCard()
        }
        .padding(.top, 20)
        .padding([.leading, .trailing], 25)
        .padding(.bottom, 10)
    }
}

