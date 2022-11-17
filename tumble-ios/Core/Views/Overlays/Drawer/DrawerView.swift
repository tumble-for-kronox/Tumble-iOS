//
//  Drawer.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 11/16/22.
//

import SwiftUI

struct DrawerView<SidebarContent: View, Content: View>: View {
    @EnvironmentObject var parentViewModel: RootView.RootViewModel
    
    let drawerContent: SidebarContent
    let mainContent: Content
    let drawerWidth: CGFloat
    
    init(drawerWidth: CGFloat, @ViewBuilder drawer: ()->SidebarContent, @ViewBuilder content: ()->Content) {
        self.drawerWidth = drawerWidth
        drawerContent = drawer()
        mainContent = content()
    }
    
    var body: some View {
        ZStack(alignment: .leading) {
            drawerContent
                .frame(width: drawerWidth, alignment: .center)
                .offset(x: parentViewModel.menuOpened ? 0 : -1 * drawerWidth, y: 0)
                .animation(Animation.easeInOut.speed(2))
            mainContent
                .overlay(
                    Group {
                        if parentViewModel.menuOpened {
                            Color.white
                                .opacity(parentViewModel.menuOpened ? 0.01 : 0)
                                .onTapGesture {
                                    parentViewModel.toggleDrawer()
                                }
                        } else {
                            Color.clear
                            .opacity(parentViewModel.menuOpened ? 0 : 0)
                            .onTapGesture {
                                parentViewModel.toggleDrawer()
                            }
                        }
                    }
                )
                .offset(x: parentViewModel.menuOpened ? drawerWidth : 0, y: 0)
                .animation(Animation.easeInOut.speed(2))
                
        }
    }
}
