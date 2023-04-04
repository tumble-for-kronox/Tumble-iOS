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
    
    @Binding var domain: String?
    @Binding var canvasUrl: String?
    @Binding var kronoxUrl: String?
    @Binding var selectedAppTab: TabbarTabType
    
    @State private var showOverlay: Bool = false
    
    var body: some View {
        VStack {
            if viewModel.homeStatus != .loading {
                News(news: viewModel.news?.pick(length: 4), showOverlay: $showOverlay)
            }
            VStack (alignment: .leading) {
                switch viewModel.homeStatus {
                case .noBookmarks:
                    HomeNoBookmarks()
                case .available:
                    HomeAvailable(
                        eventsForToday: $viewModel.eventsForToday,
                        nextClass: $viewModel.nextClass,
                        swipedCards: $viewModel.swipedCards,
                        courseColors: $viewModel.courseColors,
                        todayEventsSectionStatus: $viewModel.todayEventsSectionStatus)
                case .notAvailable:
                    HomeNotAvailable()
                case .loading:
                    CustomProgressIndicator()
                        .frame(alignment: .center)
                case .error:
                    HomeError()
                }
            }
        }
        .padding(.horizontal, 30)
        .padding(.top, 10)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.background)
        .padding(.bottom, -10)
        .sheet(isPresented: $showOverlay, content: { NewsSheet(news: viewModel.news) })
    }
    
    
    func updateCourseColors() -> Void {
        // Update instances of course colors in HomePageViewModel
        // and also callback to update in BookmarksPageViewModel
        self.parentViewModel.delegateUpdateColorsBookmarks()
    }
}
