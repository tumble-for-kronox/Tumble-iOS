//
//  HomePageSectionDivider.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 2023-03-19.
//

import SwiftUI

struct HomePageSectionDivider: View {
    let eventCount: Int
    var body: some View {
        HStack {
            Text("Today's classes")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.onBackground)
            Text("(\(eventCount))")
                .font(.system(size: 16))
                .foregroundColor(.onBackground.opacity(0.5))
            Spacer()
            Button(action: {
                // change tabbar
                withAnimation(.spring()) {
                    AppController.shared.selectedLocalTab = .bookmarks
                }
                AppController.shared.selectedAppTab = .bookmarks
            }, label: {
                Text("See all")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.primary)
            })
            .buttonStyle(HomePageSeeAllStyle())
            
        }
        .padding(.bottom, 20)
    }
}

struct HomePageSectionDivider_Previews: PreviewProvider {
    static var previews: some View {
        HomePageSectionDivider(eventCount: 3)
    }
}
