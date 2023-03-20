//
//  HomePageView.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 11/20/22.
//

import SwiftUI

struct HomePage: View {
    
    @ObservedObject var viewModel: HomePageViewModel
    
    @Binding var domain: String?
    @Binding var canvasUrl: String?
    @Binding var kronoxUrl: String?
    @Binding var selectedAppTab: TabbarTabType
    
    @Namespace var scrollSpace
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
            ScrollView (showsIndicators: false) {
                ScrollViewReader { proxy in
                    VStack {
                        HomePageUpcomingEventsSection(parentViewModel: viewModel)
                        HomePageNewsSection(parentViewModel: viewModel)
                    }
                    .background(GeometryReader { geo in
                      let offset = -geo.frame(in: .named(scrollSpace)).minY
                      Color.clear
                        .preference(key: ScrollViewOffsetPreferenceKey.self,
                                    value: offset)
                  })
                }
            }
            .coordinateSpace(name: scrollSpace)
            .onPreferenceChange(ScrollViewOffsetPreferenceKey.self) { value in
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
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.top, 20)
        .background(Color.background)
    }
}

struct ScrollViewOffsetPreferenceKey: PreferenceKey {
  static var defaultValue = CGFloat.zero

  static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
    value += nextValue()
  }
}
