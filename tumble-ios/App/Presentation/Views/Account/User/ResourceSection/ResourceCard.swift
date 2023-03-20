//
//  ResourceCard.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 2023-02-16.
//

import SwiftUI

struct ResourceCard: View {
    
    let timeSpan: String
    let location: String?
    let title: String?
    
    init(timeSpan: String, location: String? = nil, title: String? = nil) {
        self.timeSpan = timeSpan
        self.location = location
        self.title = title
    }
    
    var body: some View {
        Button(action: {}, label: {
            HStack {
                Circle()
                    .foregroundColor(.primary)
                    .frame(height: 7)
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
                Spacer()
            }
            .padding()
        })
        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 100, maxHeight: 100, alignment: .center)
        .background(Color.surface)
        .cornerRadius(20)
        .padding(.bottom, 10)
    }
}

