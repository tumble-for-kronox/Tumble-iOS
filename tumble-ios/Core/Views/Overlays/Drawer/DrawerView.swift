//
//  Drawer.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 11/16/22.
//

import SwiftUI

struct DrawerView: View {
    @EnvironmentObject var parentViewModel: RootView.RootViewModel
    let viewModel: DrawerViewModel = DrawerViewModel()
    let width: CGFloat
    
    var body: some View {
        ZStack {
            GeometryReader { _ in
                EmptyView()
            }
            .foregroundColor(.gray)
            .opacity(parentViewModel.menuOpened ? 1 : 0)
            .animation(.easeIn, value: 0.25)
            .onTapGesture {
                parentViewModel.toggleDrawer()
            }
            
            HStack {
                DrawerContent()
                    .frame(width: width, alignment: .top)
                    .offset(x: parentViewModel.menuOpened ? 0 : -width)
                Spacer()
            }
            .animation(.default)
        }
    }
}
