//
//  HomePageNewsButton.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 2023-03-20.
//

import SwiftUI

struct HomePageNewsButton: View {
    
    let notificationNewsItem: Response.NotificationContent
    
    var body: some View {
        HStack (spacing: 0) {
            Divider()
                .foregroundColor(.onBackground)
                .padding(.vertical, 15)
            VStack (alignment: .leading, spacing: 10) {
                HStack {
                    Text(notificationNewsItem.title)
                        .font(.system(size: 17, weight: .medium))
                        .foregroundColor(.onSurface)
                        .lineLimit(1)
                        .truncationMode(.tail)
                    Spacer()
                }
                HStack (alignment: .top) {
                    Image(systemName: "quote.bubble")
                        .font(.system(size: 15))
                        .foregroundColor(.onSurface.opacity(0.7))
                    Text(notificationNewsItem.body)
                        .font(.system(size: 15))
                        .foregroundColor(.onSurface.opacity(0.7))
                }
            }
            .padding()
            Spacer()
        }
    }
}

