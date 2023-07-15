//
//  NewsSheet.swift
//  Tumble
//
//  Created by Adis Veletanlic on 2023-04-05.
//

import SwiftUI

struct NewsSheet: View {
    let news: Response.NewsItems?
    
    @Binding var showSheet: Bool
    @State private var searching: Bool = false
    @State private var searchText: String = ""
    @State private var closeButtonOffset: CGFloat = 300.0
    
    var filteredNews: [Response.NotificationContent] {
        guard let news = news, !searchText.isEmpty else {
            return news ?? []
        }
        
        return news.filter { $0.title.localizedCaseInsensitiveContains(searchText) }
    }
    
    var body: some View {
        NavigationView {
            VStack {
                SearchField(
                    search: nil,
                    clearSearch: nil,
                    title: "Search news",
                    searchBarText: $searchText,
                    searching: $searching,
                    disabled: .constant(false)
                )
                .padding(.top, 55)
                if !searching {
                    ScrollView(showsIndicators: false) {
                        RecentNews(news: news)
                        AllNews(news: news)
                    }
                    .padding([.top, .horizontal], 15)
                } else {
                    ScrollView(showsIndicators: false) {
                        ForEach(filteredNews, id: \.self) { newsItem in
                            NewsItemCard(newsItem: newsItem)
                        }
                    }
                    .padding([.top, .horizontal], 15)
                }
                Spacer()
            }
            .frame(maxHeight: .infinity)
            .background(Color.background)
            .overlay(
                CloseCoverButton(onClick: onClose),
                alignment: .topTrailing
            )
            .overlay(
                Text(NSLocalizedString("News", comment: ""))
                    .sheetTitle()
                ,alignment: .top
            )
        }
    }
    
    func onClose() {
        showSheet = false
    }
}
