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

/// All navigation occurs from this view
struct MainAppView: View {
    
    @ObservedObject var viewModel: MainAppViewModel
    @State var selectedSideBarTab: SideBarTabType = .home
    @State var eventSheet: EventSheet? = nil
    @State var selectedBottomTab: BottomTabType = .home
    @State var showMenu: Bool = false
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
                SideBarMenuView(selectedSideBarTab: $selectedSideBarTab, selectedBottomTab: $selectedBottomTab, universityImage: viewModel.getUniversityImage()!, universityName: viewModel.getUniversityName()!)
            }
            
            ZStack {
                FadedPageView(backgroundOpacity: 0.6, offset: -25, verticalPadding: 30, showMenu: $showMenu)
                FadedPageView(backgroundOpacity: 0.4, offset: -50, verticalPadding: 60, showMenu: $showMenu)
                NavigationView {
                    VStack {
                        // Main home page view switcher
                        switch selectedBottomTab {
                        case .home:
                            HomePageView(viewModel: viewModel.homePageViewModel)
                        case .schedule:
                            ScheduleMainPageView(viewModel: viewModel.schedulePageViewModel, onTapCard: { (event, color) in
                                onOpenEventSheet(event: event, color: color)
                            })
                        case .account:
                            AccountPageView(viewModel: viewModel.accountPageViewModel)
                        case .settings:
                            EmptyView()
                        }
                        Spacer()
                        BottomBarView(selectedBottomTab: $selectedBottomTab, selectedSideBarTab: $selectedSideBarTab)
                            .padding([.top], 10)
                    }
                    .navigationTitle(selectedBottomTab.displayName)
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .navigationBarLeading, content: {
                            SideBarToggleButtonView(showMenu: $showMenu)
                        })
                        ToolbarItem(placement: .navigationBarTrailing, content: {
                            SearchButtonView(checkForNewSchedules: checkForNewSchedules)
                        })
                    }.background(Color.background)
                    
                }
                .sheet(item: $eventSheet) { (eventSheet: EventSheet) in
                    EventDetailsView(viewModel: ViewModelFactory().makeViewModelEventSheet(event: eventSheet.event, color: eventSheet.color))
                }
                .onDisappear {
                    // on disappear of sidebar sheet, change to the sidebar
                    // tab to be bottom tab
                }
                .cornerRadius(showMenu ? 15 : 0)
            }
            .scaleEffect(showMenu ? 0.84 : 1)
            .offset(x: showMenu ? getRect().width - 120 : 0)
            .ignoresSafeArea()
        }
    }
    
    func onOpenEventSheet(event: Response.Event, color: Color) -> Void {
        self.eventSheet = EventSheet(event: event, color: color)
    }
    
    func onSelectSchool(school: School) -> Void {
        viewModel.onSelectSchool(school: school)
    }
    
    func checkForNewSchedules() -> Void {
        viewModel.schedulePageViewModel.loadSchedules()
    }
}

