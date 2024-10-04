//
//  NewsItemDetails.swift
//  Tumble
//
//  Created by Adis Veletanlic on 2023-04-05.
//

import SwiftUI

struct NewsItemDetails: View {
    let newsItem: Response.NotificationContent
    @Environment(\.dismiss) var dismiss
    
    func close() -> Void {
        dismiss()
    }
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading) {
                Text(newsItem.title)
                    .font(.system(size: 30, weight: .semibold))
                    .foregroundColor(.onBackground)
                    .padding(.bottom, Spacing.large)
                Text(newsItem.timestamp.formatDate() ?? "")
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(.onBackground.opacity(0.8))
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            VStack(alignment: .leading) {
                Divider()
                    .opacity(0.8)
                    .padding(.vertical, Spacing.medium)
                Text(newsItem.body)
                    .font(.system(size: 16, weight: .regular))
                    .foregroundColor(.onBackground)
            }
            .padding(.trailing, Spacing.small)
            Spacer()
        }
        .padding(.horizontal, Spacing.medium)
        .padding(.top, Spacing.header)
        .background(Color.background)
        .overlay(
            CloseCoverButton(onClick: close),
            alignment: .topTrailing
        )
        .overlay(
            Text(NSLocalizedString("Details", comment: ""))
                .sheetTitle(),
            alignment: .top
        )
    }
}
