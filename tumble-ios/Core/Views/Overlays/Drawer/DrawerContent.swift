//
//  DrawerContent.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 11/16/22.
//

import SwiftUI

struct DrawerContent: View {
    @StateObject private var viewModel = DrawerViewModel()
    let showSheet: (Int) -> Void
    var body: some View {
        ZStack {
            Color("PrimaryColor").opacity(0.75)
            VStack (alignment: .center, spacing: 0) {
                Group {
                    DrawerItem(onClick: {
                        showSheet(0)
                    }, title: "School", image: "arrow.left.arrow.right")
                    DrawerItem(onClick: {
                        showSheet(1)
                        
                        
                    }, title: "Theme", image: "apps.iphone")
                    DrawerItem(onClick: {
                        showSheet(2)
                    }, title: "Language", image: "textformat.abc")
                }
                Group {
                    DrawerItem(onClick: {
                        showSheet(3)
                    }, title: "Schedules", image: "bookmark")
                }
                
                Group {
                    DrawerItem(onClick: {
                        showSheet(4)
                    }, title: "Notifications", image: "bell.badge")
                }
                Spacer()
            }
            .padding(.top, 100)
            .padding(.leading, 15)
            .padding(.trailing, 15)
            
        }
    }
}
