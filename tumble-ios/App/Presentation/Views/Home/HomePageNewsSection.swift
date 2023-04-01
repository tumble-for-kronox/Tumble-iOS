//
//  HomePageNewsSection.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 2023-03-20.
//

import SwiftUI

struct HomePageNewsSection: View {
    
    @ObservedObject var parentViewModel: HomeViewModel
    
    var body: some View {
        VStack (alignment: .leading) {
            HomePageSectionDivider(
                title: NSLocalizedString("News", comment: ""),
                contentCount: parentViewModel.news?.count ?? 0)
            switch parentViewModel.newsSectionStatus {
            case .loading:
                VStack {
                    CustomProgressIndicator()
                }
                .frame(
                    maxWidth: .infinity,
                    maxHeight: .infinity,
                    alignment: .center
                )
            case .loaded:
                if !parentViewModel.news!.isEmpty {
                    ScrollView (showsIndicators: false) {
                        LazyVStack {
                            ForEach(parentViewModel.news!, id: \.self) { notificationNewsItem in
                                HomePageNewsButton(notificationNewsItem: notificationNewsItem)
                            }
                        }
                    }
                } else {
                    Text(NSLocalizedString("No recent news items", comment: ""))
                        .font(.system(size: 18))
                        .foregroundColor(.onBackground)
                }
            case .error:
                Text(NSLocalizedString("Something went wrong", comment: ""))
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
            parentViewModel: ViewModelFactory.shared.makeViewModelHome()
        )
    }
}
