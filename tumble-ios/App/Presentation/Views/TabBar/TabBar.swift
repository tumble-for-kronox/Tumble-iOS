//
//  BottomBarView.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 2023-02-03.
//

import SwiftUI

struct TabBar: View {
    
    @Binding var selectedAppBottomTab: TabbarTabType
    @Binding var selectedLocalBottomTab: TabbarTabType
    @Namespace var animation
    
    var body: some View {
        VStack(spacing: 0) {
            Rectangle()
                .frame(height: 0.5)
                .foregroundColor(.onBackground.opacity(0.5))
                .padding(.bottom, 10)
            HStack (spacing: 0) {
                TabBarButton(animation: animation, bottomTab: .home, selectedLocalBottomTab: $selectedLocalBottomTab, selectedAppBottomTab: $selectedAppBottomTab)
                TabBarButton(animation: animation, bottomTab: .bookmarks, selectedLocalBottomTab: $selectedLocalBottomTab, selectedAppBottomTab: $selectedAppBottomTab)
                TabBarButton(animation: animation, bottomTab: .account, selectedLocalBottomTab: $selectedLocalBottomTab, selectedAppBottomTab: $selectedAppBottomTab)
            }
            .frame(minHeight: 50)
            .background(Color.background)
        }
    }
}

