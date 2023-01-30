//
//  SideBarStack.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 2023-01-29.
//

import SwiftUI

struct SideBarStack<SidebarContent: View, Content: View>: View {
    
    let sidebarContent: SidebarContent
    let mainContent: Content
    @Binding var showSidebar: Bool
    @Binding var sideBarOffset: CGFloat
    private let internalOffset: CGFloat = -110
    
    init(sideBarOffset: Binding<CGFloat>, showSidebar: Binding<Bool>, @ViewBuilder sidebar: ()->SidebarContent, @ViewBuilder content: ()->Content) {
        self._showSidebar = showSidebar
        self._sideBarOffset = sideBarOffset
        sidebarContent = sidebar()
        mainContent = content()
    }
    
    var body: some View {
        ZStack(alignment: .leading) {
            Color("SurfaceColor")
            sidebarContent
                .frame(width: 110, alignment: .leading)
                .offset(x: internalOffset)
            mainContent
                .overlay(
                    Group {
                        if showSidebar {
                            Color.white
                                .opacity(showSidebar ? 0.01 : 0)
                                .onTapGesture {
                                    withAnimation {
                                        self.sideBarOffset += internalOffset
                                    }
                                    self.showSidebar = false
                                }
                        } else {
                            Color.clear
                            .opacity(showSidebar ? 0 : 0)
                            .onTapGesture {
                                withAnimation {
                                    self.sideBarOffset += internalOffset
                                }
                                self.showSidebar = false
                            }
                        }
                    }
                )
                .offset(x: sideBarOffset)
        }
    }
}

