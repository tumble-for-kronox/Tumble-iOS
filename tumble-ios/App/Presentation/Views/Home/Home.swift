//
//  HomePageView.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 11/20/22.
//

import SwiftUI

struct Home: View {
    
    @ObservedObject var viewModel: HomeViewModel
    @ObservedObject var parentViewModel: ParentViewModel
    
    @Binding var selectedAppTab: TabbarTabType
    @State private var showSheet: Bool = false
    
    var body: some View {
        VStack {
            if viewModel.newsSectionStatus == .loaded {
                News(news: viewModel.news?.pick(length: 4), showOverlay: $showSheet)
            }
            Spacer()
            VStack (alignment: .leading) {
                switch viewModel.status {
                case .noBookmarks:
                    HomeNoBookmarks()
                case .available:
                    HomeAvailable(
                        eventsForToday: $viewModel.eventsForToday,
                        nextClass: $viewModel.nextClass,
                        swipedCards: $viewModel.swipedCards)
                case .notAvailable:
                    HomeNotAvailable()
                case .loading:
                    CustomProgressIndicator()
                        .frame(alignment: .center)
                case .error:
                    HomeError()
                }
            }
            Spacer()
        }
        .padding(.horizontal, 30)
        .padding(.top, 10)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.background)
        .padding(.bottom, -10)
        .sheet(isPresented: $showSheet, content: { NewsSheet(news: viewModel.news) })
    }
}
