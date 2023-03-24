//
//  DrawerRow.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 11/17/22.
//

import SwiftUI

struct SidebarMenuButton: View {
    let sideBarTabType: SidebarTabType
    let title: String
    let image: String
    
    @ObservedObject var parentViewModel: SidebarViewModel
    @Binding var selectedSideBarTab: SidebarTabType?
    
    var body: some View {
        Button(action: {
            withAnimation(.spring()) {
                selectedSideBarTab = sideBarTabType
                parentViewModel.sidebarSheetType = sideBarTabType
                parentViewModel.presentSidebarSheet = true
            }
        }, label: {
            HStack (spacing: 10) {
                Image(systemName: image)
                    .font(.system(size: 20))
                    .frame(width: 32)
                Text(title)
                    .fontWeight(.semibold)
                    .font(.system(size: 20))
            }
            .foregroundColor(.onSurface)
            .padding(.vertical, 12)
            .padding(.horizontal, 20)
            .frame(maxWidth: getRect().width - 170, alignment: .leading)
        })
        .padding(.top, 10)
        Divider()
            .foregroundColor(.onSurface)
            .padding(.leading, 25)
            .padding(.trailing, getRect().width / 2)
            .padding(.bottom, 10)
    }
}
