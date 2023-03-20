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
    
    let backgroundColor: Color = .primary.opacity(0.75)
    let iconColor: Color = .primary.opacity(0.95)
    
    var body: some View {
        VStack (alignment: .leading, spacing: 0) {
            HomePageHeader(parentViewModel: viewModel, domain: $domain)
            HomePageUpcomingEventsSection(parentViewModel: viewModel)
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.top, 20)
        .background(Color.background)
    }
}
