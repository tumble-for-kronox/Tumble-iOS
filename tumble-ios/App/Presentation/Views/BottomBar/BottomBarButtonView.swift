//
//  BottomBarButtonView.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 2023-02-01.
//

import SwiftUI

struct BottomBarButtonView: View {
    var animation: Namespace.ID
    let bottomTab: BottomTabType
    
    @Binding var selectedBottomTab: BottomTabType
    
    var body: some View {
        Button(action: {
            withAnimation(.spring()) {
                self.selectedBottomTab = bottomTab
            }
        }, label: {
            VStack(spacing: 8) {
                Image(systemName: bottomTab.rawValue)
                    .font(.system(size: 22))
                    .foregroundColor(selectedBottomTab.rawValue == bottomTab.rawValue ? .primary : .onBackground.opacity(0.5))
                if selectedBottomTab.rawValue == bottomTab.rawValue {
                    Circle()
                        .fill(Color.primary)
                        .matchedGeometryEffect(id: "BOTTOMTAB", in: animation)
                        .frame(width: 8, height: 8)
                }
            }
            .frame(maxWidth: .infinity)
        })
    }
}
