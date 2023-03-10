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
                    .frame(width: 25, height: 2)
                    .cornerRadius(10)
                Capsule()
                   .fill(Color.onBackground.opacity(0.8))
                   .frame(width: 25, height: 2)
                   .cornerRadius(10)
                Capsule()
                   .fill(Color.onBackground.opacity(0.8))
                   .frame(width: 25, height: 2)
                   .cornerRadius(10)
            }
        })
    }
}

