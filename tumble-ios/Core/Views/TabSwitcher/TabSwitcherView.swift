//
//  HomeView.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 11/20/22.
//

import SwiftUI

struct TabSwitcherView: View {
    @StateObject var viewModel: TabSwitcherViewModel = TabSwitcherViewModel()
    let drawerWidth: CGFloat = UIScreen.main.bounds.width/3
    var body: some View {
        ZStack(alignment: .leading) {
            Color("BackgroundColor")
            DrawerView(drawerWidth: drawerWidth)
                .environmentObject(viewModel)
                .sheet(isPresented: $viewModel.showDrawerSheet, onDismiss: {
                    viewModel.onToggleDrawerSheet()
                }, content: {
                    viewModel.currentDrawerSheetView
                })
            NavigationView {
                ZStack {
                    Color("BackgroundColor")
                    VStack (alignment: .center) {
                        // Main home page view switcher
                        viewModel.currentNavigationView
                        TabBarView()
                            .environmentObject(viewModel)
                    }
                }
                .navigationTitle(
                    Text(viewModel.selectedTab.displayName))
                .navigationBarTitleDisplayMode(.inline)
                .navigationBarItems(leading: Button(action: {
                    viewModel.onToggleDrawer()
                }, label: {
                    Image(systemName: viewModel.menuOpened ? "xmark" : "line.3.horizontal")
                        .font(.system(size: 17))
                        .foregroundColor(Color("OnBackground"))
                }), trailing: NavigationLink(destination:
                    SearchParentView()
                    .navigationBarBackButtonHidden(true)
                    .navigationBarItems(leading: BackButton()), label: {
                    Image(systemName: "magnifyingglass")
                            .font(.system(size: 17))
                        .foregroundColor(Color("OnBackground"))
                }))
                .background(Color("BackgroundColor"))
                    .font(.system(size: 22))
            }
            .overlay(
                Group {
                    if viewModel.menuOpened {
                        Color("BackgroundColor")
                            .opacity(viewModel.menuOpened ? 0.01 : 0)
                            .onTapGesture {
                                viewModel.onToggleDrawer()
                            }
                    } else {
                        Color.clear
                        .opacity(viewModel.menuOpened ? 0 : 0)
                        .onTapGesture {
                            viewModel.onToggleDrawer()
                        }
                    }
                }
            )
            .offset(x: viewModel.menuOpened ? drawerWidth : 0, y: 0)
            .animation(Animation.easeIn.speed(2.0), value: viewModel.menuOpened)
            .animation(Animation.easeOut.speed(2.0), value: !viewModel.menuOpened)

        }        
        .edgesIgnoringSafeArea(.all)
    }
}
