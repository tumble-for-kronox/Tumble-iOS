//
//  BottomBarView.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 2023-02-03.
//

import SwiftUI

struct TabBar: View {
    
    @Binding var selectedBottomTab: TabbarTabType
    @Namespace var animation
    
    var body: some View {
        HStack (spacing: 0) {
            TabBarButton(animation: animation, bottomTab: .home, selectedBottomTab: $selectedBottomTab)
            TabBarButton(animation: animation, bottomTab: .bookmarks, selectedBottomTab: $selectedBottomTab)
            TabBarButton(animation: animation, bottomTab: .account, selectedBottomTab: $selectedBottomTab)
        }
        .background(Color.background)
    }
}
