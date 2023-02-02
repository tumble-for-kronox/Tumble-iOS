//
//  SideBarToggleButtonView.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 2023-02-01.
//

import SwiftUI

struct SideBarToggleButtonView: View {
    @Binding var showSideBar: Bool
    @Binding var selectedSideBarTab: SideBarTabType
    var body: some View {
        Button(action: {
            withAnimation(.spring()) {
                showSideBar.toggle()
                selectedSideBarTab = .none
            }
        }, label: {
            VStack (spacing: 5) {
                 Capsule()
                    .fill(Color.onBackground)
                    .frame(width: 25, height: showSideBar ? 3 : 2)
                    .rotationEffect(.init(degrees: showSideBar ? -45 : 0))
                    .offset(x: showSideBar ? 2 : 0, y: showSideBar ? 8.3 : 0)
                // These two capsules appear animated
                VStack (spacing: 5) {
                    Capsule()
                       .fill(Color.onBackground)
                       .frame(width: 25, height: 2)
                    Capsule()
                       .fill(Color.onBackground)
                       .frame(width: 25, height: 2)
                       .offset(y: showSideBar ? -8 : 0)
                }
                .rotationEffect(.init(degrees: showSideBar ? 43 : 0))
            }
        })
    }
}

