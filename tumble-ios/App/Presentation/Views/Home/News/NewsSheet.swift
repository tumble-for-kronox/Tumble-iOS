//
//  NewsSheet.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 2023-04-05.
//

import SwiftUI

struct NewsSheet: View {
    
    let news: Response.NewsItems?
    
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
                DraggingPill()
                SheetTitle(title: NSLocalizedString("News", comment: ""))
                HStack {
                    SearchButton(search: {})
                    TextField(
                        NSLocalizedString("Search news", comment: ""),
                        text: $searchText,
                        onEditingChanged: onEditingChanged
                    )
                    .searchBoxText()
                    CloseButton(
                        onClearSearch: onClearSearch,
                        animateCloseButtonOutOfView: animateCloseButtonOutOfView,
                        closeButtonOffset: $closeButtonOffset,
                        searchBarText: $searchText)
                }
                .searchBox()
                .onSubmit {
                    hideKeyboard()
                }
                if !searching {
                    ScrollView (showsIndicators: false) {
                        RecentNews(news: news)
                        AllNews(news: news)
                    }
                    .padding([.top, .horizontal], 15)
                } else {
                    ScrollView (showsIndicators: false) {
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
        }
    }
    
    func onEditingChanged(value: Bool) -> Void {
        if searchText.isEmpty {
            withAnimation(.easeOut) {
                searching = value
                animateCloseButtonIntoView()
            }
        } else {
            hideKeyboard()
        }
    }
    
    fileprivate func animateCloseButtonOutOfView() -> Void {
        withAnimation(.spring().delay(0.5)) {
            closeButtonOffset += 300
        }
    }
    
    fileprivate func animateCloseButtonIntoView() -> Void {
        if self.closeButtonOffset == 300.0 {
            withAnimation(.spring().delay(0.5)) {
                closeButtonOffset -= 300
            }
        }
    }
    
    func onClearSearch(endEditing: Bool) -> Void {
        if searching {
            if searchText.isEmpty {
                withAnimation(.easeInOut) {
                    searching = false
                }
            } else {
                searchText = ""
            }
        } else {
            withAnimation(.easeInOut) {
                searching = false
            }
        }
    }
    
}
