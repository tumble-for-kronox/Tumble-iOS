//
//  HomeView.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 11/16/22.
//

import Foundation

import SwiftUI


struct RootView: View {
    @StateObject private var viewModel = RootViewModel()
    
    var body: some View {
        ZStack {
            Color("BackgroundColor")
                .ignoresSafeArea()
            HomeView()
                .environmentObject(viewModel)
                // Picker sheet will appear if school is not set
                .sheet(isPresented: $viewModel.missingSchool) {
                    SchoolSelectView(selectSchoolCallback: { school in
                        viewModel.selectSchool(school: school)
                    }).interactiveDismissDisabled(true)
                
            }
        }
    }
}

struct HomeView: View {
    @EnvironmentObject var rootViewModel: RootView.RootViewModel
    let drawerWidth: CGFloat = UIScreen.main.bounds.width/1.3
    var body: some View {
        ZStack(alignment: .leading) {
            DrawerView(drawerWidth: drawerWidth)
                .environmentObject(rootViewModel)
                .sheet(isPresented: $rootViewModel.showDrawerSheet, content: {
                    switch rootViewModel.drawerSheetType {
                    case 0:
                        SchoolSelectView(selectSchoolCallback: { schoolName in
                            rootViewModel.selectSchool(school: schoolName)
                        })
                    default:
                        Text("")
                    }
                })
            NavigationView {
                VStack {
                    VStack {
                        Spacer()
                        BottomBarView()
                            .environmentObject(rootViewModel)
                            
                    }
                }
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .principal) {
                        VStack {
                            Text(rootViewModel.selectedTab.displayName)
                                .font(.headline)
                                .foregroundColor(.black)
                        }
                    }
                }
                .navigationBarItems(leading: Button(action: {
                    rootViewModel.toggleDrawer()
                }, label: {
                    Image(systemName: "gearshape")
                        .foregroundColor(.black)
                }), trailing: NavigationLink(destination: SearchView(), label: {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.black)
                }))
                    .foregroundColor(.gray)
                    .font(.system(size: 22))
            }
            .overlay(
                Group {
                    if rootViewModel.menuOpened {
                        Color.white
                            .opacity(rootViewModel.menuOpened ? 0.01 : 0)
                            .onTapGesture {
                                rootViewModel.toggleDrawer()
                            }
                    } else {
                        Color.clear
                        .opacity(rootViewModel.menuOpened ? 0 : 0)
                        .onTapGesture {
                            rootViewModel.toggleDrawer()
                        }
                    }
                }
            )
            .offset(x: rootViewModel.menuOpened ? drawerWidth : 0, y: 0)
            .animation(Animation.easeInOut.speed(2))

        }
        .edgesIgnoringSafeArea(.all)
    }
}
