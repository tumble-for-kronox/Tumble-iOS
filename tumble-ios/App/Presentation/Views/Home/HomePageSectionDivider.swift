//
//  HomePageSectionDivider.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 2023-03-19.
//

import SwiftUI

struct HomePageSectionDivider: View {
    
    let onTapSeeAll: () -> Void
    let title: String
    let contentCount: Int
    
    var body: some View {
        HStack {
            Text(title)
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.onBackground)
                .environment(\.locale, Locale(identifier: "sv"))
            Text("(\(contentCount))")
                .font(.system(size: 16))
                .foregroundColor(.onBackground.opacity(0.5))
            Spacer()
            Button(action: onTapSeeAll, label: {
                Text(NSLocalizedString("See all", comment: ""))
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.primary)
            })
            .buttonStyle(HomePageSeeAllStyle())
            
        }
        .padding(.bottom, 20)
        .padding(.top)
    }
}

struct HomePageSectionDivider_Previews: PreviewProvider {
    static var previews: some View {
        HomePageSectionDivider(
            onTapSeeAll: {},
            title: "Today's events",
            contentCount: 3
        )
    }
}
