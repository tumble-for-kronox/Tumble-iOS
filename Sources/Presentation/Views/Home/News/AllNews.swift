//
//  AllNews.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 2023-04-05.
//

import SwiftUI

struct AllNews: View {
    let news: Response.NewsItems?
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text(NSLocalizedString("Other news", comment: ""))
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.onBackground)
                Spacer()
            }
            if let news = news {
                VStack(alignment: .leading) {
                    if news.isEmpty {
                        Text(NSLocalizedString("No other news", comment: ""))
                            .font(.system(size: 16))
                            .foregroundColor(.onBackground)
                            .padding(.top, 7.5)
                    } else {
                        ForEach(news[4...], id: \.self) { newsItem in
                            NewsItemCard(newsItem: newsItem)
                        }
                    }
                }
            }
        }
        .padding(.top, 30)
    }
}
