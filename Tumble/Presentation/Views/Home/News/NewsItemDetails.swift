//
//  NewsItemDetails.swift
//  Tumble
//
//  Created by Adis Veletanlic on 2023-04-05.
//

import SwiftUI

struct NewsItemDetails: View {
    let newsItem: NetworkResponse.NotificationContent
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading) {
                Text(newsItem.title)
                    .font(.system(size: 30, weight: .semibold))
                    .foregroundColor(.onBackground)
                    .padding(.bottom, 20)
                Text(newsItem.timestamp.formatDate() ?? "")
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(.onBackground.opacity(0.8))
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            VStack(alignment: .leading) {
                Divider()
                    .opacity(0.8)
                    .padding(.vertical, 15)
                Text(newsItem.body)
                    .font(.system(size: 16, weight: .regular))
                    .foregroundColor(.onBackground)
            }
            .padding(.trailing, 10)
            Spacer()
        }
        .padding([.horizontal, .top], 15)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        .background(Color.background)
        .navigationTitle(NSLocalizedString("Details", comment: ""))
    }
}
