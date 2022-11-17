//
//  DrawerView.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 11/17/22.
//

import SwiftUI

struct DrawerView: View {
    @EnvironmentObject var rootViewModel: RootView.RootViewModel
    var drawerWidth: CGFloat
    var body: some View {
        DrawerContent(showSheet: { id in
            rootViewModel.onClickDrawerRow(index: id)
        })
        .frame(width: drawerWidth, alignment: .center)
        .offset(x: rootViewModel.menuOpened ? 0 : -1 * drawerWidth, y: 0)
        .animation(Animation.easeInOut.speed(2))
        
    }
}
