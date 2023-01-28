//
//  BottomBarItem.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 2023-01-25.
//

import SwiftUI

struct BottomBarItem: View {
    let selectedTab: TabType
    let thisTab: TabType
    let fillImage: String
    let skeletonImage: String
    let onChangeTab: OnChangeTab
    let animateTransition: Bool
    var body: some View {
        VStack (spacing: 0) {
            Image(systemName: selectedTab == thisTab ? fillImage : thisTab.rawValue)
                .scaleEffect(selectedTab == thisTab ? 1.10 : 1.0)
                .foregroundColor(self.foregroundColor())
                .font(.mediumIconFont)
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
        .animation(Animation.easeIn.speed(5), value: animateTransition)
    }
    
    func foregroundColor() -> Color {
        return selectedTab == thisTab ? Color("PrimaryColor").opacity(0.85) : Color("OnBackground")
    }
}


