//
//  DrawerView.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 11/17/22.
//

import SwiftUI

typealias HandleDrawerItemClick = (DrawerRowType) -> Void

struct DrawerView: View {
    @EnvironmentObject var parentViewModel: AppNavigatorView.AppNavigatorViewModel
    var onClickDrawerRow: HandleDrawerItemClick
    var drawerWidth: CGFloat
    var body: some View {
        DrawerContent(showSheet: { drawerType in
            onClickDrawerRow(drawerType)
        })
        .frame(width: drawerWidth, alignment: .leading)
        .offset(x: parentViewModel.menuOpened ? 0 : -drawerWidth, y: 0)
        .animation(.easeIn.speed(2), value: parentViewModel.menuOpened)
        .animation(.easeOut.speed(2), value: !parentViewModel.menuOpened)
        
    }
}
