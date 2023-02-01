//
//  BottomBarItem.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 2023-01-25.
//

import SwiftUI

struct BottomBarItem: View {
    let selectedTab: BottomTabType
    let thisTab: BottomTabType
    let fillImage: String
    let skeletonImage: String
    let onChangeTab: OnChangeTab
    var body: some View {
        VStack (spacing: 0) {
            Image(systemName: selectedTab == thisTab ? fillImage : thisTab.rawValue)
                .scaleEffect(selectedTab == thisTab ? 1.10 : 1.0)
                .foregroundColor(self.foregroundColor())
                .font(.system(size: 15, design: .rounded))
                .onTapGesture {
                    if !(selectedTab == thisTab) {
                        onChangeTab(thisTab)
                    }
                }
                .padding(.bottom, 4)
            Text(thisTab.displayName)
                .bottomBarItem(selectedTab: selectedTab, thisTab: thisTab)
                .scaleEffect(selectedTab == thisTab ? 1.10 : 1.0)
                
        }
    }
    
    func foregroundColor() -> Color {
        return selectedTab == thisTab ? Color("PrimaryColor").opacity(0.85) : Color("OnBackground")
    }
}


