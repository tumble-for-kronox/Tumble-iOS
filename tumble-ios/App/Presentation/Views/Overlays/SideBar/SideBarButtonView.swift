//
//  DrawerRow.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 11/17/22.
//

import SwiftUI

struct SideBarButtonView: View {
    let sideBarTabType: SideBarTabType
    let title: String
    let image: String
    @Binding var selectedSideBarTab: SideBarTabType
    @Binding var selectedBottomTab: BottomTabType
    var animation: Namespace.ID
    
    var body: some View {
        Button(action: {
            withAnimation(.spring()) {
                selectedSideBarTab = sideBarTabType
                translateSideBarToBottomTab(sideBarTab: sideBarTabType)
            }
        }, label: {
            HStack (spacing: 10) {
                Image(systemName: image)
                    .font(.system(size: 18, design: .rounded))
                    .frame(width: 30)
                Text(title)
                    .fontWeight(.semibold)
            }
            .foregroundColor(selectedSideBarTab.rawValue == title ? .primary : .surface)
            .padding(.vertical, 12)
            .padding(.horizontal, 20)
            .frame(maxWidth: getRect().width - 170, alignment: .leading)
            .background(
                // Hero animation
                ZStack {
                    if selectedSideBarTab.rawValue == title {
                        Color.surface.opacity(selectedSideBarTab.rawValue == title ? 1 : 0)
                            .clipShape(CustomCorners(corners: [.topRight, .bottomRight], radius: 10))
                            .matchedGeometryEffect(id: "SIDEBARTAB", in: animation)
                    }
                }
            )
        })
    }
    
    func translateSideBarToBottomTab(sideBarTab: SideBarTabType) -> Void {
        switch sideBarTab {
        case .home:
            selectedBottomTab = BottomTabType.home
        case .schedule:
            selectedBottomTab = BottomTabType.schedule
        case .account:
            selectedBottomTab = BottomTabType.account
        case .settings:
            selectedBottomTab = BottomTabType.settings
        case .theme:
            print("change theme")
        case .notifications:
            print("open notifications drawer")
        case .school:
            print("open schedule drawer")
        case .support:
            print("open support drawer")
        case .logOut:
            print("log out callback")
        }
    }
}
