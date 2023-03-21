//
//  ResourceCard.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 2023-02-16.
//

import SwiftUI

struct ResourceCard: View {
    
    let date: String
    let timeSpan: String
    let location: String?
    let title: String?
    
    init(timeSpan: String,
         location: String? = nil,
         title: String? = nil,
         date: String) {
        self.timeSpan = timeSpan
        self.location = location
        self.title = title
        self.date = date
    }
    
    var body: some View {
        Button(action: {}, label: {
            HStack {
                Circle()
                    .foregroundColor(.primary)
                    .frame(width: 7, height: 7)
                    .padding(.trailing, 0)
                Text(timeSpan)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.onSurface)
            }
            .padding(.horizontal)
            Divider()
                .foregroundColor(.onSurface)
            VStack (alignment: .leading, spacing: 10) {
                Text(title ?? "No title")
                    .font(.system(size: 17, weight: .medium))
                    .foregroundColor(.onSurface)
                    .lineLimit(1)
                    .truncationMode(.tail)
                HStack {
                    Image(systemName: "mappin.and.ellipse")
                        .font(.system(size: 15))
                        .foregroundColor(.onSurface.opacity(0.7))
                    Text(location ?? "Unknown")
                        .font(.system(size: 15))
                        .foregroundColor(.onSurface.opacity(0.7))
                }
                HStack {
                    Image(systemName: "calendar.badge.clock")
                        .font(.system(size: 15))
                        .foregroundColor(.onSurface.opacity(0.7))
                    Text(date)
                        .font(.system(size: 15))
                        .foregroundColor(.onSurface.opacity(0.7))
                }
            }
            .padding()
        })
        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 110, maxHeight: 110, alignment: .center)
        .background(Color.surface)
        .cornerRadius(20)
        .padding(.bottom, 10)
    }
}

