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
    @State private var showSideBarSheet = false
    @State private var showScheduleEventSheet = false
    @State private var pickerSheetView: AnyView? = nil
    @State private var eventSheetPositionSize: CGSize = CGSize(width: 0, height: UIScreen.main.bounds.height)
    @State private var blurRadius: CGFloat = .zero
    @State private var showSideBar: Bool = false
    @State var sideBarOffset: CGFloat = .zero
    
    private let sideBarWidth: CGFloat = 110
    
    init(viewModel: MainAppViewModel) {
        UINavigationBar.appearance().titleTextAttributes = [.font: navigationBarFont()]
        self.viewModel = viewModel
    }
    
    var body: some View {
        SideBarStack(sideBarOffset: $sideBarOffset, showSidebar: $showSideBar) {
            SideBarContent(viewModel: viewModel.sideBarViewModel, showSheet: { drawerType in
                    onClickDrawerRow(drawerRowType: drawerType)
                })
                .frame(width: sideBarWidth, alignment: .center)
                .offset(x: sideBarOffset + 7)
                } content: {
                    NavigationView {
                        ZStack {
                            // Main home page view switcher
                            switch viewModel.selectedTab {
                            case .home:
                                HomePageView(viewModel: viewModel.homePageViewModel)
                            case .schedule:
                                ScheduleMainPageView(viewModel: viewModel.schedulePageViewModel, onTapCard: { (event, color) in
                                    onToggleScheduleEventSheet(event: event, color: color)
                                })
                            case .account:
                                AccountPageView(viewModel: viewModel.accountPageViewModel)
                            }
                        }
                        .navigationTitle(viewModel.selectedTab.displayName)
                        .navigationBarTitleDisplayMode(.inline)
                        .toolbar {
                            ToolbarItem(placement: .navigationBarLeading, content: {
                                SideBarButtonView(onToggleDrawer: onToggleDrawer, sideBarOpened: showSideBar)
                                    
                            })
                            ToolbarItem(placement: .navigationBarTrailing, content: {
                                SearchButtonView(checkForNewSchedules: checkForNewSchedules)
                            })
                            ToolbarItemGroup(placement: .bottomBar, content: {
                                BottomBarView(onChangeTab: onChangeTab).environmentObject(viewModel)
                                    .padding([.bottom, .top], 10)
                            })
                        }.background(Color.background)
                    }
                    // Sheet toggled from sidebar content
                    .sheet(isPresented: $showSideBarSheet) {
                        SideBarSheetView(currentSideBarSheetView: viewModel.currentSideBarSheetView!, onSelectSchool: onSelectSchool, toggleDrawerSheet: onToggleSideBarSheet)
                    }.onDisappear {
                        onToggleSideBarSheet()
                    }
                    .sheet(isPresented: $showScheduleEventSheet) {
                        pickerSheetView
                    }
                    .onDisappear {
                        self.showScheduleEventSheet = false
                    }
                }.edgesIgnoringSafeArea(.all)
        
    }
    
    func onChangeTab(tab: TabType) -> Void {
        withAnimation (.easeIn(duration: 0.1)) {
            viewModel.onChangeTab(tab: tab)
        }
    }
    
    func onToggleSideBarSheet() -> Void {
        self.showSideBarSheet.toggle()
    }
    
    func onToggleScheduleEventSheet(event: Response.Event, color: Color) -> Void {
        self.pickerSheetView = AnyView(EventDetailsView(event: event, color: color))
        self.showScheduleEventSheet.toggle()
    }
    
    func onToggleDrawer() -> Void {
        withAnimation {
            if showSideBar {
                sideBarOffset -= 110
            } else {
                sideBarOffset += 110
            }
            showSideBar.toggle()
        }
    }
    
    func onSelectSchool(school: School) -> Void {
        viewModel.onSelectSchool(school: school)
    }
    
    func checkForNewSchedules() -> Void {
        viewModel.schedulePageViewModel.loadSchedules()
    }
    
    // Assigns the corresponding drawer view type
    // based on which row in the drawer was clicked
    func onClickDrawerRow(drawerRowType: DrawerRowType) -> Void {
        switch drawerRowType {
        case .school:
            viewModel.currentSideBarSheetView = .school
        case .schedules:
            viewModel.currentSideBarSheetView = .schedules
        case .support:
            viewModel.currentSideBarSheetView = .support
        default:
            viewModel.currentSideBarSheetView = nil
        }
        if viewModel.currentSideBarSheetView != nil {
            showSideBarSheet = true
        }
    }
}

