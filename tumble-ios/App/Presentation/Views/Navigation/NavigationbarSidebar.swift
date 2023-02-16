//
//  SideBarToggleButtonView.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 2023-02-01.
//

import SwiftUI

struct NavigationbarSidebar: View {
    @Binding var showSideBar: Bool
    @Binding var selectedSideBarTab: SidebarTabType
    let handleClose: (Bool, SidebarTabType) -> Void
    var body: some View {
        Button(action: {
            withAnimation(.spring()) {
                handleClose(showSideBar ? false : true, showSideBar ? .none : .none)
            }
        }, label: {
            VStack (spacing: 5) {
                 Capsule()
                    .fill(Color.onBackground.opacity(0.8))
                    .frame(width: 25, height: showSideBar ? 3 : 2)
                    .rotationEffect(.init(degrees: showSideBar ? -45 : 0))
                    .offset(x: showSideBar ? 2 : 0, y: showSideBar ? 8.3 : 0)
                    .cornerRadius(10)
                // These two capsules appear animated
                VStack (spacing: 5) {
                    Capsule()
                       .fill(Color.onBackground.opacity(0.8))
                       .frame(width: 25, height: 2)
                       .cornerRadius(10)
                    Capsule()
                       .fill(Color.onBackground.opacity(0.8))
                       .frame(width: 25, height: 2)
                       .offset(y: showSideBar ? -8 : 0)
                       .cornerRadius(10)
                }
                .rotationEffect(.init(degrees: showSideBar ? 43 : 0))
            }
        })
    }
}

