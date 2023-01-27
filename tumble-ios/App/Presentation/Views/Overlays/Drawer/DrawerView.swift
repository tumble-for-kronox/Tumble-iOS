//
//  DrawerView.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 11/17/22.
//

import SwiftUI

typealias HandleDrawerItemClick = (DrawerRowType) -> Void

struct DrawerView: View {
    var isDrawerOpened: Bool
    var onClickDrawerRow: HandleDrawerItemClick
    var drawerWidth: CGFloat
    var body: some View {
        DrawerContent(viewModel: ViewModelFactory().makeViewModelDrawer(), showSheet: { drawerType in
            onClickDrawerRow(drawerType)
        })
        .frame(width: drawerWidth, alignment: .leading)
        .offset(x: isDrawerOpened ? 0 : -drawerWidth, y: 0)
        .animation(.easeIn.speed(2), value: isDrawerOpened)
        .animation(.easeOut.speed(2), value: !isDrawerOpened)
        
    }
}
