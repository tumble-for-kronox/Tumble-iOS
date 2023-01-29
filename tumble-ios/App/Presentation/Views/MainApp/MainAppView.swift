//
//  HomeView.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 11/20/22.
//

import SwiftUI


/// All navigation occurs from this view
struct MainAppView: View {
    @ObservedObject var viewModel: MainAppViewModel
    
    @State private var isPickerSheetPresented = false
    @State private var pickerSheetView: AnyView? = nil
    @State private var eventSheetPositionSize: CGSize = CGSize(width: 0, height: UIScreen.main.bounds.height)
    @State private var blurRadius: CGFloat = 0
    @State private var showSideBar: Bool = false
    
    private let drawerWidth: CGFloat = UIScreen.main.bounds.width/3
    
    init(viewModel: MainAppViewModel) {
        UINavigationBar.appearance().titleTextAttributes = [.font : UIFont(name: "Montserrat-Regular", size: 18)!]
        self.viewModel = viewModel
    }
    
    var body: some View {
        SideBarStack(sidebarWidth: 125, showSidebar: $showSideBar) {
            SideBarContent(viewModel: viewModel.sideBarViewModel, showSheet: { drawerType in
                    viewModel.onClickDrawerRow(drawerRowType: drawerType)
                })
                .frame(width: drawerWidth, alignment: .leading)
                .offset(x: showSideBar ? 0 : -drawerWidth, y: 0)
                .animation(.easeIn.speed(2), value: showSideBar)
                .animation(.easeOut.speed(2), value: !showSideBar)
                } content: {
                    NavigationView {
                        ZStack {
                            // Main home page view switcher
                            switch viewModel.selectedTab {
                            case .home:
                                HomePageView(viewModel: viewModel.homePageViewModel).onAppear {
                                    viewModel.onEndTransitionAnimation()
                                }
                            case .schedule:
                                ScheduleMainPageView(viewModel: viewModel.schedulePageViewModel, onTapCard: { event in
                                    self.animateEventSheetIntoView()
                                }).onAppear{
                                    viewModel.onEndTransitionAnimation()
                                }
                            case .account:
                                AccountPageView(viewModel: viewModel.accountPageViewModel).onAppear {
                                    viewModel.onEndTransitionAnimation()
                                }
                                
                            }
                        }
                        .navigationTitle(viewModel.selectedTab.displayName)
                        .navigationBarTitleDisplayMode(.inline)
                        .toolbar {
                            ToolbarItem(placement: .navigationBarLeading, content: {
                                DrawerButtonView(onToggleDrawer: onToggleDrawer, menuOpened: showSideBar)
                            })
                            ToolbarItem(placement: .navigationBarTrailing, content: {
                                SearchButtonView(checkForNewSchedules: checkForNewSchedules)
                            })
                            ToolbarItemGroup(placement: .bottomBar, content: {
                                BottomBarView(onChangeTab: onChangeTab).environmentObject(viewModel)
                            })
                        }.background(Color("BackgroundColor"))
                            
                    }
                }.edgesIgnoringSafeArea(.all)
        
    }
    
    func onChangeTab(tab: TabType) -> Void {
        withAnimation (.easeIn(duration: 0.1)) {
            viewModel.onChangeTab(tab: tab)
        }
    }
    
    func animateEventSheetIntoView() -> Void {
        self.eventSheetPositionSize.height = .zero
        withAnimation (.easeIn) { self.blurRadius = 3 }
    }
    
    func animateEventSheetOutOfView() -> Void {
        self.eventSheetPositionSize.height = UIScreen.main.bounds.height
        withAnimation (.easeOut) { self.blurRadius = 0 }
    }
    
    func onToggleDrawer() -> Void {
        withAnimation {
            showSideBar.toggle()
        }
    }
    
    func onToggleDrawerSheet() -> Void {
        viewModel.showDrawerSheet.toggle()
    }
    
    func onSelectSchool(school: School) -> Void {
        viewModel.onSelectSchool(school: school)
    }
    
    func eventSheetToggled() -> Bool {
        return self.eventSheetPositionSize.height < UIScreen.main.bounds.height
    }
    
    func checkForNewSchedules() -> Void {
        viewModel.schedulePageViewModel.loadSchedules()
    }
}

