//
//  NewsItemCard.swift
//  Tumble
//
//  Created by Adis Veletanlic on 2023-04-05.
//

import SwiftUI

struct NewsItemCard: View {
    let newsItem: Response.NotificationContent
    
    var body: some View {
        NavigationLink(destination: AnyView(NewsItemDetails(newsItem: newsItem)), label: {
            VStack(alignment: .leading, spacing: 0) {
                HStack {
                    Text(newsItem.title)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.onSurface)
                    Spacer()
                    Text(newsItem.timestamp.formatDate() ?? "")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.onSurface.opacity(0.8))
                }
                .padding(.bottom, 7.5)
                Text(newsItem.body)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.onSurface)
                    .multilineTextAlignment(.leading)
            }
            .padding(10)
            .frame(maxWidth: .infinity)
            .background(Color.surface)
            .cornerRadius(10)
            .padding(.vertical, 7.5)
        })
    }
}
