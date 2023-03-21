//
//  HomePageNewsSection.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 2023-03-20.
//

import SwiftUI

struct HomePageNewsSection: View {
    
    @ObservedObject var parentViewModel: HomePageViewModel
    
    var body: some View {
        VStack (alignment: .leading) {
            HomePageSectionDivider(onTapSeeAll: {
                // Open sheet with all news items
            }, title: "News", contentCount: parentViewModel.news?.count ?? 0)
            switch parentViewModel.newsSectionStatus {
            case .loading:
                Spacer()
                HStack {
                    Spacer()
                    CustomProgressIndicator()
                    Spacer()
                }
                Spacer()
            case .loaded:
                if !parentViewModel.news!.isEmpty {
                    ScrollView {
                        LazyVStack {
                            ForEach(parentViewModel.news!, id: \.self) { notificationNewsItem in
                                HomePageNewsButton(notificationNewsItem: notificationNewsItem)
                            }
                        }
                    }
                } else {
                    Text("No news for today")
                        .font(.system(size: 18))
                        .foregroundColor(.onBackground)
                }
            case .error:
                Text("Something went wrong")
                    .font(.system(size: 18))
                    .foregroundColor(.onBackground)
            }
        }
        .padding(.bottom, 30)
    }
}

struct HomePageNewsSection_Previews: PreviewProvider {
    static var previews: some View {
        HomePageNewsSection(
            parentViewModel: ViewModelFactory.shared.makeViewModelHomePage()
        )
    }
}
