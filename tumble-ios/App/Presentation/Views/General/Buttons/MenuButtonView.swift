//
//  DrawerButtonView.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 2023-01-26.
//

import SwiftUI

typealias OnToggleDrawer = () -> Void

struct MenuButtonView: View {
    
    let onToggleDrawer: OnToggleDrawer
    let sideBarOpened: Bool
    
    private let closed: String = "line.3.horizontal"
    private let opened: String = "xmark"
    
    var body: some View {
        Button(action: {
            onToggleDrawer()
        }, label: {
            Image(systemName: sideBarOpened ? opened : closed)
                .font(.system(size: 17))
                .foregroundColor(.onBackground)
        })
    }
}

