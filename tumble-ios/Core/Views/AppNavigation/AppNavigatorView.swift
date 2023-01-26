//
//  HomeView.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 11/20/22.
//

import SwiftUI

struct AppNavigatorView: View {
    let drawerWidth: CGFloat = UIScreen.main.bounds.width/3
    @StateObject var viewModel: AppNavigatorViewModel = AppNavigatorViewModel()
    @State private var isPickerSheetPresented = false
    @State private var pickerSheetView: AnyView? = nil
    
    
    init() {
      let coloredAppearance = UINavigationBarAppearance()
      coloredAppearance.configureWithOpaqueBackground()
      coloredAppearance.backgroundColor = UIColor(Color("BackgroundColor"))
      
      UINavigationBar.appearance().standardAppearance = coloredAppearance
      UINavigationBar.appearance().compactAppearance = coloredAppearance
      UINavigationBar.appearance().scrollEdgeAppearance = coloredAppearance
      
      UINavigationBar.appearance().tintColor = .white
    }

    
    var body: some View {
        ZStack(alignment: .leading) {
            Color("BackgroundColor")
            DrawerView(onClickDrawerRow: { draweRowType in
                viewModel.onClickDrawerRow(drawerRowType: draweRowType)
            }, drawerWidth: drawerWidth)
                .environmentObject(viewModel)
                
            NavigationView {
                ZStack {
                    Color("BackgroundColor")
                    VStack (alignment: .center) {
                        // Main home page view switcher
                        if viewModel.schoolIsChosen {
                            switch viewModel.selectedTab {
                            case .home:
                                HomePageView().onAppear {
                                    viewModel.onEndTransitionAnimation()
                                }
                            case .schedule:
                                ScheduleMainPageView().onAppear{
                                    viewModel.onEndTransitionAnimation()
                                }
                            case .account:
                                AccountPageView().onAppear {
                                    viewModel.onEndTransitionAnimation()
                                }
                                
                            }
                        }
                        Spacer()
                        
                    }
                    
                    .padding([.leading, .trailing], 5)
                }
                .navigationTitle(
                    Text(viewModel.selectedTab.displayName))
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading, content: {
                        Button(action: {
                            viewModel.onToggleDrawer()
                        }, label: {
                            Image(systemName: viewModel.menuOpened ? "xmark" : "line.3.horizontal")
                                .font(.system(size: 17))
                                .foregroundColor(Color("OnBackground"))
                        })
                    })
                    ToolbarItem(placement: .navigationBarTrailing, content: {
                        NavigationLink(destination:
                            SearchParentView()
                            .navigationBarBackButtonHidden(true)
                            .navigationBarItems(leading: BackButton()), label: {
                            Image(systemName: "magnifyingglass")
                                    .font(.system(size: 17))
                                .foregroundColor(Color("OnBackground"))
                        })
                    })
                    ToolbarItemGroup(placement: .bottomBar, content: {
                        Spacer()
                        BottomBarItem(selectedTab: viewModel.selectedTab, thisTab: .home, fillImage: TabType.home.rawValue + ".fill", skeletonImage: TabType.home.rawValue, onChangeTab: onChangeTab, animateTransition: viewModel.animateTransition)
                        Spacer()
                        BottomBarItem(selectedTab: viewModel.selectedTab, thisTab: .schedule, fillImage: TabType.schedule.rawValue + ".fill", skeletonImage: TabType.schedule.rawValue, onChangeTab: onChangeTab, animateTransition: viewModel.animateTransition)
                        Spacer()
                        BottomBarItem(selectedTab: viewModel.selectedTab, thisTab: .account, fillImage: TabType.account.rawValue + ".fill", skeletonImage: TabType.account.rawValue, onChangeTab: onChangeTab, animateTransition: viewModel.animateTransition)
                        Spacer()
                    })
                }
                .background(Color("BackgroundColor"))
                .font(.system(size: 22))
            }
            .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
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
            .sheet(isPresented: $viewModel.showDrawerSheet, onDismiss: {
                viewModel.onToggleDrawerSheet()
            }, content: {
                viewModel.currentDrawerSheetView
            })
        }
    }
    
    func onChangeTab(tab: TabType) -> Void {
        viewModel.onChangeTab(tab: tab)
    }
}


struct AppNavigatorView_Previews: PreviewProvider {
    static var previews: some View {
        AppNavigatorView()
    }
}
