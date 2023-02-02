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
    @Binding var sideBarSheet: SideBarSheet?
    var animation: Namespace.ID
    
    var body: some View {
        Button(action: {
            withAnimation(.spring()) {
                selectedSideBarTab = sideBarTabType
                sideBarSheet = SideBarSheet(sideBarType: sideBarTabType)
            }
        }, label: {
            HStack (spacing: 10) {
                Image(systemName: image)
                    .font(.system(size: 20))
                    .frame(width: 32)
                Text(title)
                    .fontWeight(.semibold)
                    .font(.system(size: 20, design: .rounded))
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
}
