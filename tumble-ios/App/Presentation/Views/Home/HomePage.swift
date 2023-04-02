//
//  HomePageView.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 11/20/22.
//

import SwiftUI

struct HomePage: View {
    
    @ObservedObject var viewModel: HomeViewModel
    @ObservedObject var parentViewModel: ParentViewModel
    
    @Binding var domain: String?
    @Binding var canvasUrl: String?
    @Binding var kronoxUrl: String?
    @Binding var selectedAppTab: TabbarTabType
    
    var scrollSpace: String = "homeRefreshable"
    @State var scrollOffset: CGFloat = .zero
    
    @State private var collapsedHeader: Bool = false
    
    let backgroundColor: Color = .primary.opacity(0.75)
    let iconColor: Color = .primary.opacity(0.95)
    @State private var position = 0
    var body: some View {
        VStack (alignment: .leading, spacing: 0) {
            HomePageHeader(
                parentViewModel: viewModel,
                domain: $domain,
                collapsedHeader: $collapsedHeader
            )
            if !collapsedHeader {
                PullToRefreshIndicator()
            }
            ScrollView (showsIndicators: false) {
                Refreshable(coordinateSpaceName: scrollSpace, onRefresh: {
                    viewModel.getNews()
                })
                ScrollViewReader { proxy in
                    VStack {
                        HomePageUpcomingEventsSection(parentViewModel: viewModel)
                        HomePageNewsSection(parentViewModel: viewModel)
                    }
                    .background(GeometryReader { geo in
                        let offset = -geo.frame(in: .named(scrollSpace)).minY
                        Color.clear
                            .preference(key: HomeScrollViewOffsetPreferenceKey.self,
                                        value: offset)
                    })
                }
            }
            .padding(.bottom, -10)
            .coordinateSpace(name: scrollSpace)
            .onPreferenceChange(HomeScrollViewOffsetPreferenceKey.self, perform: handleScroll)
            Spacer()
        }
        .sheet(item: $viewModel.eventSheet) { (eventSheet: EventDetailsSheetModel) in
            EventDetailsSheet(
                viewModel: viewModel.generateViewModelEventSheet(
                    event: eventSheet.event,
                    color: eventSheet.color),
                updateCourseColors: updateCourseColors)
        }
        .padding(.horizontal, 16)
        .padding(.top, 20)
        .background(Color.background)
    }
    
    func updateCourseColors() -> Void {
        // Update instances of course colors in HomePageViewModel
        // and also callback to update in BookmarksPageViewModel
        self.parentViewModel.delegateUpdateColorsBookmarks()
    }
    
    func handleScroll(value: CGFloat) -> Void {
        scrollOffset = value
        if scrollOffset >= 64 {
            withAnimation(.easeInOut) {
                collapsedHeader = true
            }
        } else {
            withAnimation(.easeInOut) {
                collapsedHeader = false
            }
        }
    }
    
}

fileprivate struct HomeScrollViewOffsetPreferenceKey: PreferenceKey {
  static var defaultValue = CGFloat.zero

  static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
    value += nextValue()
  }
}
