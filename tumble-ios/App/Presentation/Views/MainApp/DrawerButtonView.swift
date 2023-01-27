//
//  DrawerButtonView.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 2023-01-26.
//

import SwiftUI

typealias OnToggleDrawer = () -> Void

struct DrawerButtonView: View {
    let onToggleDrawer: OnToggleDrawer
    let menuOpened: Bool
    var body: some View {
        Button(action: {
            onToggleDrawer()
        }, label: {
            Image(systemName: menuOpened ? "xmark" : "line.3.horizontal")
                .font(.system(size: 17))
                .foregroundColor(Color("OnBackground"))
        })
    }
}

