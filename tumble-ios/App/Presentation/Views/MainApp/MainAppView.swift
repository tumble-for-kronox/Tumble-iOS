//
//  HomeView.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 11/20/22.
//

// The sidebar menu used in this project:
// https://kavsoft.dev/swiftui_2.0_animated_navigation_menu

import SwiftUI

struct EventSheet: Identifiable {
    var id: UUID = UUID()
    let event: Response.Event
    let color: Color
}

struct SideBarSheet: Identifiable {
    var id: UUID = UUID()
    let sideBarType: SideBarTabType
}

/// All navigation occurs from this view
struct MainAppView: View {
    
    @ObservedObject var viewModel: MainAppViewModel
    
    @State private var toast: Toast? = nil
    @State var selectedSideBarTab: SideBarTabType = .none
    @State var eventSheet: EventSheet? = nil
    @State var sideBarSheet: SideBarSheet? = nil
    @State var selectedBottomTab: BottomTabType = .home
    @State var showSideBar: Bool = false
    @Namespace var animation
    
    private let sideBarWidth: CGFloat = 110
    
    init(viewModel: MainAppViewModel) {
        UINavigationBar.appearance().titleTextAttributes = [.font: navigationBarFont()]
        self.viewModel = viewModel
    }
    
    var body: some View {
        ZStack {
            Color.primary
                .ignoresSafeArea()
            
            ScrollView (getRect().height < 750 ? .vertical : .init(), showsIndicators: false) {
                SideBarMenuView(selectedSideBarTab: $selectedSideBarTab, selectedBottomTab: $selectedBottomTab, sideBarSheet: $sideBarSheet, universityImage: viewModel.universityImage ?? Image(systemName: "building.columns"), universityName: viewModel.universityName ?? "")
            }
            
            ZStack {
                FadedPageView(backgroundOpacity: 0.6, offset: -25, verticalPadding: 30, showSideBar: $showSideBar)
                FadedPageView(backgroundOpacity: 0.4, offset: -50, verticalPadding: 60, showSideBar: $showSideBar)
                NavigationView {
                    VStack {
                        // Main home page view switcher
                        switch selectedBottomTab {
                        case .home:
                            HomePageView(viewModel: viewModel.homePageViewModel)
                        case .schedule:
                            ScheduleMainPageView(viewModel: viewModel.schedulePageViewModel, onTapCard: { (event, color) in
                                onOpenEventDetailsSheet(event: event, color: color)
                            })
                        case .account:
                            AccountPageView(viewModel: viewModel.accountPageViewModel)
                        }
                        Spacer()
                        BottomBarView(selectedBottomTab: $selectedBottomTab)
                            .padding([.top], 10)
                    }
                    .navigationTitle(selectedBottomTab.displayName)
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .navigationBarLeading, content: {
                            SideBarToggleButtonView(showSideBar: $showSideBar, selectedSideBarTab: $selectedSideBarTab)
                        })
                        ToolbarItem(placement: .navigationBarTrailing, content: {
                            SearchNavigationButtonView(backButtonTitle: selectedBottomTab.displayName, checkForNewSchedules: checkForNewSchedules)
                        })
                    }.background(Color.background)
                    
                }
                .sheet(item: $eventSheet) { (eventSheet: EventSheet) in
                    EventDetailsSheetView(viewModel: ViewModelFactory().makeViewModelEventDetailsSheet(event: eventSheet.event, color: eventSheet.color))
                }
                .onDisappear {
                    selectedSideBarTab = .none
                }
                .sheet(item: $sideBarSheet) { (sideBarSheet: SideBarSheet) in
                    SideBarSheetView(sideBarTabType: sideBarSheet.sideBarType, onChangeSchool: onChangeSchool)
                }
                .cornerRadius(showSideBar ? 15 : 0)
            }
            .scaleEffect(showSideBar ? 0.84 : 1)
            .offset(x: showSideBar ? getRect().width - 120 : 0)
            .toastView(toast: $toast)
            .ignoresSafeArea()
        }
    }
    
    func onChangeSchool(school: School) -> Void {
        viewModel.changeSchool(school: school, closure: {
            toast = Toast(type: .success, title: "New school", message: "Set \(school.name) to default")
            viewModel.updateUniversityLocalsForView()
            checkForNewSchedules()
        })
    }
    
    func checkForNewSchedules() -> Void {
        viewModel.checkForNewSchedules()
    }
    
    func onOpenEventDetailsSheet(event: Response.Event, color: Color) -> Void {
        self.eventSheet = EventSheet(event: event, color: color)
    }
}

