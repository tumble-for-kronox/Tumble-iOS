//
//  DrawerView.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 11/17/22.
//

import SwiftUI

struct DrawerView: View {
    @EnvironmentObject var parentViewModel: TabSwitcherView.TabSwitcherViewModel
    var drawerWidth: CGFloat
    var body: some View {
        DrawerContent(showSheet: { id in
            parentViewModel.onClickDrawerRow(drawerSheetType: id)
        })
        .frame(width: drawerWidth, alignment: .center)
        .offset(x: parentViewModel.menuOpened ? 0 : -1 * drawerWidth, y: 0)
        .animation(.easeIn.speed(2), value: parentViewModel.menuOpened)
        .animation(.easeOut.speed(2), value: !parentViewModel.menuOpened)
        
    }
}
