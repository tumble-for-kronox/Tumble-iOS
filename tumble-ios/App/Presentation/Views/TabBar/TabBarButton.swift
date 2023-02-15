//
//  BottomBarButtonView.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 2023-02-01.
//

import SwiftUI

struct TabBarButton: View {
    var animation: Namespace.ID
    let bottomTab: TabbarTabType
    
    @Binding var selectedBottomTab: TabbarTabType
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: bottomTab.rawValue)
                .tabBarIcon(isSelected: isSelected())
            if isSelected() {
                RoundedRectangle(cornerSize: CGSize(width: 16, height: 8))
                    .fill(Color.primary)
                    .matchedGeometryEffect(id: "BOTTOMTAB", in: animation)
                    .frame(width: 20, height: 4)
            }
        }
        .frame(maxWidth: .infinity)
        .onTapGesture {
            withAnimation(.spring()) {
                self.selectedBottomTab = bottomTab
            }
        }
    }
    
    private func isSelected() -> Bool {
        return selectedBottomTab.rawValue == bottomTab.rawValue
    }
    
}


