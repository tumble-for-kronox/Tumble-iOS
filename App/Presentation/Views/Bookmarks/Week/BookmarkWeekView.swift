//
//  WeekView.swift
//  Tumble
//
//  Created by Adis Veletanlic on 2023-06-06.
//

import SwiftUI

struct BookmarkWeekView: View {
    let scheduleWeeks: [Int : [Day]]
    @State private var currentPage = 0
    @ObservedObject var viewModel: BookmarksViewModel
    
    var body: some View {
        ZStack(alignment: .bottom) {
            TabView(selection: $currentPage) {
                ForEach(weekStartDates.indices, id: \.self) { index in
                    WeekPage(
                        weekStart: weekStartDates[index],
                        weekDays: scheduleWeeks[weekStartDates[index].get(.weekOfYear)] ?? [],
                        toggleViewSwitcherVisibility: viewModel.toggleViewSwitcherVisibility
                    )
                    .tag(index)
                    .preference(key: CurrentPagePreferenceKey.self, value: index)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .always))
            .onPreferenceChange(CurrentPagePreferenceKey.self) { value in
                currentPage = value
            }
            
            VStack {
                CustomPageControlView(numberOfPages: weekStartDates.count, currentPage: $currentPage)
                    .frame(width: 100, height: 20)
                    .padding(.bottom, 55 + Spacing.medium)
                    .shadow(color: .black.opacity(0.1), radius: 1)
            }
            .offset(y: viewModel.viewSwitcherVisible ? 0: 100)
            .scaleEffect(viewModel.viewSwitcherVisible ? 1 : 0.8, anchor: .bottom)
            .opacity(viewModel.viewSwitcherVisible ? 1 : 0.5)
        }
    }
}

