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
        VStack (alignment: .center, spacing: 0) {
            Group {
                
            }
            Group {
                
                SideBarItem(onClick: {
                    showSheet(.schedules)
                }, title: "Schedules", image: "bookmark")
                SideBarItem(onClick: {
                    showSheet(.school)
                }, title: "School", image: "arrow.left.arrow.right")
                
                
            }
            Group {
                SideBarItem(onClick: {
                    showSheet(.support)
                }, title: "Support", image: "questionmark.circle")
                
            }
            Spacer()
            Text("Tumble for Kronox V.3.0.0")
                .appVersionDrawer()
        }
        .padding(.top, 90)
        .padding(.leading, 15)
        .padding(.trailing, 15)
    }
}
