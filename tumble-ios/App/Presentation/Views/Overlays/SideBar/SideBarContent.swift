//
//  DrawerContent.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 11/16/22.
//

import SwiftUI

struct SideBarContent: View {
    @ObservedObject var viewModel: SideBarViewModel
    let showSheet: (DrawerRowType) -> Void
    var body: some View {
        HStack {
            VStack (alignment: .center, spacing: 1) {
                SideBarItem(onClick: {
                    showSheet(.schedules)
                }, title: "Schedules", image: "bookmark")
                SideBarItem(onClick: {
                    showSheet(.school)
                }, title: "School", image: "arrow.left.arrow.right")
                SideBarItem(onClick: {
                    showSheet(.support)
                }, title: "Support", image: "questionmark.circle")
                Spacer()
                Text("Tumble for Kronox V.3.0.0")
                    .appVersionDrawer()
            }
            .padding(.top, 90)
            .padding(.leading, 15)
            .padding(.trailing, 15)
            Spacer()
        }
    }
}

struct SideBarContent_Previews: PreviewProvider {
    static var previews: some View {
        SideBarContent(viewModel: ViewModelFactory().makeViewModelSideBar(), showSheet: {drawerType in})
    }
}
