//
//  SideBarToggleButtonView.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 2023-02-01.
//

import SwiftUI

struct SideBarToggleButtonView: View {
    @Binding var showMenu: Bool
    var body: some View {
        Button(action: {
            withAnimation(.spring()) {
                showMenu.toggle()
            }
        }, label: {
            VStack (spacing: 5) {
                 Capsule()
                    .fill(Color.onBackground)
                    .frame(width: 25, height: showMenu ? 3 : 2)
                    .rotationEffect(.init(degrees: showMenu ? -45 : 0))
                    .offset(x: showMenu ? 2 : 0, y: showMenu ? 8.3 : 0)
                // These two capsules appear animated
                VStack (spacing: 5) {
                    Capsule()
                       .fill(Color.onBackground)
                       .frame(width: 25, height: 2)
                    Capsule()
                       .fill(Color.onBackground)
                       .frame(width: 25, height: 2)
                       .offset(y: showMenu ? -8 : 0)
                }
                .rotationEffect(.init(degrees: showMenu ? 43 : 0))
            }
        })
    }
}

