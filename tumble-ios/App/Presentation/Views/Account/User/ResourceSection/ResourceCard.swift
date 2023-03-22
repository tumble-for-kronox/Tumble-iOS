//
//  ResourceCard.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 2023-02-16.
//

import SwiftUI

struct ResourceCard: View {
    
    let date: String
    let hoursMinutes: String
    let timeSpan: String
    let type: String?
    let location: String?
    let title: String?
    
    init(timeSpan: String,
         type: String? = nil,
         title: String? = nil,
         location: String? = nil,
         date: String,
         hoursMinutes: String) {
        self.timeSpan = timeSpan
        self.type = type
        self.title = title
        self.date = date
        self.hoursMinutes = hoursMinutes
        self.location = location
    }
    
    var body: some View {
        Button(action: {}, label: {
            VStack (alignment: .leading, spacing: 10) {
                Text(title ?? "No title")
                    .font(.system(size: 17, weight: .medium))
                    .foregroundColor(.onSurface)
                    .lineLimit(1)
                    .truncationMode(.tail)
                if let type = type {
                    HStack {
                        Image(systemName: "info.bubble")
                            .font(.system(size: 15))
                            .foregroundColor(.onSurface.opacity(0.7))
                        Text(type)
                            .font(.system(size: 15))
                            .foregroundColor(.onSurface.opacity(0.7))
                    }
                }
                if let location = location {
                    HStack {
                        Image(systemName: "mappin.and.ellipse")
                            .font(.system(size: 15))
                            .foregroundColor(.onSurface.opacity(0.7))
                        Text(location)
                            .font(.system(size: 15))
                            .foregroundColor(.onSurface.opacity(0.7))
                    }
                }
                HStack {
                    Image(systemName: "calendar.badge.clock")
                        .font(.system(size: 15))
                        .foregroundColor(.onSurface.opacity(0.7))
                    Text("\(date) from \(hoursMinutes)")
                        .font(.system(size: 15))
                        .foregroundColor(.onSurface.opacity(0.7))
                }
            }
            .padding()
        })
        .buttonStyle(CompactButtonStyle())
    }
}

