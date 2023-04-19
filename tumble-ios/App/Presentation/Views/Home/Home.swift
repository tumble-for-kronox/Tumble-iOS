//
//  HomePageView.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 11/20/22.
//

import SwiftUI
import RealmSwift

struct Home: View {
    
    @ObservedObject var viewModel: HomeViewModel
    @ObservedObject var parentViewModel: ParentViewModel
    @ObservedResults(Schedule.self) var schedules
    
    @Binding var selectedAppTab: TabbarTabType
    @State private var showSheet: Bool = false
    
    var body: some View {
        VStack {
            if viewModel.newsSectionStatus == .loaded {
                News(news: viewModel.news?.pick(length: 4), showOverlay: $showSheet)
            }
            Spacer()
            VStack (alignment: .leading) {
                if schedules.isEmpty {
                    HomeNoBookmarks()
                } else {
                    if schedules.filter({ $0.toggled }).isEmpty {
                        HomeNotAvailable()
                    } else {
                        HomeAvailable(
                            eventsForToday: $viewModel.eventsForToday,
                            nextClass: viewModel.nextClass,
                            swipedCards: $viewModel.swipedCards)
                    }
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
