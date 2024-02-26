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
        ZStack {
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
                    .padding(.top, 100)
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
                .edgesIgnoringSafeArea(.all)
                .frame(maxHeight: .infinity)
                .background(Color.background)
                .navigationTitle(NSLocalizedString("News", comment: ""))
                .navigationBarTitleDisplayMode(.inline)
            }
            
            VStack {
                HStack {
                    Spacer()
                    CloseCoverButton(onClick: onClose)
                }
                Spacer()
            }
        }
    }
    
    func onClose() {
        showSheet = false
    }
}
