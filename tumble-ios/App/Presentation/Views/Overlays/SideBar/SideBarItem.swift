//
//  DrawerRow.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 11/17/22.
//

import SwiftUI

struct SideBarItem: View {
    var onClick: () -> Void
    let title: String
    let image: String
    var body: some View {
        VStack {
            Button(action: onClick, label: {
                Image(systemName: image)
                    .drawerIcon()
                
            })
            Text(title)
                .caption().foregroundColor(Color("OnBackground"))
                
        }
        .padding(.bottom, 30)
    }
}
