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
            HomeView()
                .environmentObject(viewModel)
                // Picker sheet will appear if school is not set
                .sheet(isPresented: $viewModel.missingSchool) {
                    SchoolSelectView(selectSchoolCallback: { schoolName in
                        viewModel.selectSchool(school: schoolName)
                    }).interactiveDismissDisabled(true)
                
            }
        }
    }
}

struct HomeView: View {
    @EnvironmentObject var rootViewModel: RootView.RootViewModel
    var body: some View {
        DrawerView(drawerWidth: UIScreen.main.bounds.width/2, drawer: {
            DrawerContent()
        }, content: {
            NavigationView {
                VStack {
                    VStack {
                        switch rootViewModel.selectedTab {
                        case Tab.house:
                            Text("House!")
                        case Tab.calendar:
                            Text("Calendar!")
                        case Tab.account:
                            Text("Account!")
                        }
                    }
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
                            Text(rootViewModel.selectedTab.displayName).font(.headline)
                                .foregroundColor(.black)
                        }
                    }
                }
                .navigationBarItems(leading: Button(action: {
                    rootViewModel.toggleDrawer()
                }, label: {
                    Image(systemName: "gearshape")
                        .foregroundColor(.black)
                }), trailing: Button(action: {
                    
                }, label: {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.black)
                }))
                    .foregroundColor(.gray)
                    .font(.system(size: 22))
            }
        }).edgesIgnoringSafeArea(.all)
    }
}
