//
//  HomeView.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 11/20/22.
//

import SwiftUI
import PopupView

struct TabSwitcherView: View {
    @StateObject var viewModel: TabSwitcherViewModel = TabSwitcherViewModel()
    let drawerWidth: CGFloat = UIScreen.main.bounds.width/3.25
    var body: some View {
        ZStack(alignment: .leading) {
            DrawerView(drawerWidth: drawerWidth)
                .environmentObject(viewModel)
                .sheet(isPresented: $viewModel.showDrawerSheet, onDismiss: {
                    viewModel.onToggleDrawerSheet()
                }, content: {
                    viewModel.currentDrawerSheetView
                })
            NavigationView {
                VStack {
                    VStack {
                        ScrollView {
                            // Main home page view switcher
                            viewModel.currentNavigationView
                        }
                        TabBarView()
                            .environmentObject(viewModel)
                            
                    }
                }
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .principal) {
                        VStack {
                            Text(viewModel.selectedTab.displayName)
                                .font(.headline)
                                .foregroundColor(.black)
                                .padding(.top, 10)
                        }
                    }
                }
                .navigationBarItems(leading: Button(action: {
                    viewModel.onToggleDrawer()
                }, label: {
                    Image(systemName: "gearshape")
                        .foregroundColor(.black)
                }), trailing: NavigationLink(destination:
                    SearchView()
                    .navigationBarBackButtonHidden(true)
                    .navigationBarItems(leading: BackButton()), label: {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.black)
                }))
                    .foregroundColor(.gray)
                    .font(.system(size: 22))
            }
            .overlay(
                Group {
                    if viewModel.menuOpened {
                        Color.white
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
