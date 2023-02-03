//
//  BottomBarView.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 2023-02-03.
//

import SwiftUI

struct BottomBarView: View {
    
    @Binding var selectedBottomTab: BottomTabType
    @Namespace var animation
    
    var body: some View {
        HStack (spacing: 0) {
            BottomBarButtonView(animation: animation, bottomTab: .home, selectedBottomTab: $selectedBottomTab)
            BottomBarButtonView(animation: animation, bottomTab: .bookmarks, selectedBottomTab: $selectedBottomTab)
            BottomBarButtonView(animation: animation, bottomTab: .account, selectedBottomTab: $selectedBottomTab)
        }
        .background(Color.background)
    }
}
